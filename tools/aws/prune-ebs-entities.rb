#! /usr/bin/env ruby
require 'optparse'
require 'json'
require 'time'

#********************************************************
# Author: Bryan Praditkul
# Date: 20130601
# Note: This was one of my few attempts at ruby.  While I never got into the language, at least I made something work :)
#

#********************************************************
# The following script deletes EBS Volumes/Snapshots
# that are:
# 1) volumes tags are older than a user defined day count
#    and are marked in "available"/"error" status
# 2) snapshots are not in the "exclusion" list of tags
# 3) snaphots are older than a user defined day count
# 
# Also, for "available" volumes, tag them with "Last Used" and set the current date
# Once the a device is found in to be in use, remove that tag.

# Usage:
# prune-ebs-entities.rb --days <days> [--exclude <exclude file>] --verbose --dry-run [--help]
#     --days|-d		Days to Keep
#     --exclude|-e	Exclusion File (file of ASGs to exclude from pruning)
#			Setting the tag: "PurgeAllow = false" will also exclude the object from be excluded
#     --verbose|-v	Additional Information
#     --dry-run|-n	Output what will be pruned, but don't execute any pruning
#     --help|-h		This message
#
# 

#***************************
#Get a few other creds
#
OWNERID = <AWS ID>

File.readlines("/etc/<some-config-directory>/awsconfig.sh").each do |line|
   line.delete!("\n")
   line.gsub! "export ", ""
   line.delete! '\"'
   values = line.split("=")
   ENV[values[0]] = values[1]
end

options = {}
OptionParser.new do |opts|
   opts.banner = "Usage: prune-ebs-entities [options]"
   opts.on('-d', '--days DAYS', Integer, 'Days to keep') { |v| options[:days] = v }
   opts.on('-e', '--exclude FILE', 'Path to Exclude File. Setting the tag: "PurgeAllow = false" will also exclude entry') { |v| options[:exclude] = v }
   opts.on('-t', '--type TYPE', 'Type of resource (volume|snapshot|both)') { |v| options[:type] = v }
   opts.on('-v', '--verbose', 'Additional Information') { |v| options[:verbose] = v }
   opts.on('-n', '--dry-run', 'No Execute; Dry Run Only') { |v| options[:dryrun] = v }
   opts.on_tail('-h', '--help', 'Help (this message)') do
      puts opts
      exit
   end
end.parse!

if options[:verbose]
   p options
end

case options[:type]
when 'volume'
   pruneVols(options)
when 'snapshot'
   pruneSnaps(options)
when 'both'
   pruneVols(options)
   pruneSnaps(options)
else
   puts 'Invalid type option'
end

BEGIN { 

#***************************
# getExclusions - Offer the ability to exclude groups of volumes and snapshots through a config file
# For individual objects, it's easier/better to add the 
# tag "PurgeAllow = false" to the specified EBS resources
# To use, create a config file of the following format
# TagValue,{v,s} # v - volumes, s - snapshots
# eg. <StackName>,v  # for all volumes related to <StackName>
#
def getExclusions(options)
   excludes = Hash.new {|h,k| h[k]=[]}

   if File.exist?("#{options[:exclude]}") 
      File.foreach(options[:exclude]) do |line| 
         key, value = line.split(',')
         value.delete!("\n")
         if value == 'v'
            excludes["volume"].push(key)
         elsif value == 's'
            excludes["snapshots"].push(key)
	 else
         end 
      end
   end

   return excludes
end

#***************************
# pruneSnaps - Snapshot Management
#
def pruneSnaps(options)
   available_snaps_cmd = "aws ec2 describe-snapshots --owner-ids #{OWNERID} --output text --query \"Snapshots[*].[VolumeId,SnapshotId,StartTime,Size,State,Tags]\""

   results = `#{available_snaps_cmd}`.split("\n")

   excludes = getExclusions(options)

   puts "Processing #{results.count} snapshots..." if options[:verbose]

   #Iterate through each result 
   #
   results.each_with_index do |line, i|
      vol_id, snap_id, create_time, size, state, tags = line.split("\t")

      if options[:verbose]
         puts "Snapshot #{i+1}/#{results.count}: [#{snap_id}]"
         puts "   State: #{state}" 
      end

      now = Time.now
    
      #A little cleanup on the tag string before we can parse the JSON
      tags.gsub! 'u\'','\''
      tags.gsub! '\'','"' 
      tags.delete! ("\n")

      tags_hash = Hash[]

      if tags != "None"
         tags_array = JSON.parse(tags)
         tags_array.each do |x| 
            puts "     Tag: #{x['Key']} => #{x['Value']}" if options[:verbose]
            tags_hash[:"#{x['Key']}"] = "#{x['Value']}" 
         end
      end

      #Know what needs to be exempt
      excludes.each do |key,array_of_values| 
         array_of_values.each do |value|
            if tags_hash.has_value?(value) || snap_id == value
               state = 'skip'
            end
         end
      end
      state = 'skip' if tags_hash[:PurgeAllow] == "false"

            
      case state 
      when 'skip' 
 	 puts "Snapshot #{snap_id} was found in the exclusion list.  Skipping." if options[:verbose]
      when 'error'       #Objects in "error" state is essentially useless
         deleteEBSResource("snapshot","#{snap_id}")
      when 'pending'     #Leave "pending" objects alone until they're ready
         puts "#{snap_id} is in pending state. Skipping" if options[:verbose]
      when 'completed'   #Delete objects if they've been tagged some time ago
         if tags_hash.key?(:LastUsed)
  	    if options.has_key?(:days) && (now-(Time.parse(tags_hash[:LastUsed])) > ((options[:days]).to_i)*24*3600)
               if options[:dryrun]
                  puts "On execute, would delete #{snap_id} since last used: #{tags_hash[:LastUsed]}" 
               else
   	          puts "Deleting #{snap_id}: Last Used #{tags_hash[:LastUsed]}"
                  deleteEBSResource("snapshot","#{snap_id}")
     	       end
            end
         else 	          #If there's no tag, it's possibly new, so tag it
            add_last_used_key_cmd = "aws ec2 create-tags --resources #{snap_id} --tags \"Key=LastUsed,Value=\'#{now}\'\""  
 	    if options[:dryrun]
	       puts "On execute, would add LastUsed tag to #{snap_id}"
	    else
	       puts "Adding LastUsed=#{now} tag to #{snap_id}"
               err = IO.popen(add_last_used_key_cmd) 
	       err.autoclose = true
	       sleep 5
            end
            puts "setting key/value with cmd: #{add_last_used_key_cmd}" if options[:verbose] 
         end
      else
         puts "#{snap_id} is in UNKNOWN state" if options[:verbose]
      end
   end
end

#**********************************
# pruneVols - Manage EBS Volumes
#
def pruneVols(options)
   available_vols_cmd = "aws ec2 describe-volumes --output text --query \"Volumes[*].[VolumeId,SnapshotId,CreateTime,Size,State,Tags]\""

   results = `#{available_vols_cmd}`.split("\n")

   excludes = getExclusions(options)

   #Iterate through each result 
   #
   results.each_with_index do |line, i|
      vol_id, snap_id, create_time, size, state, tags = line.split("\t")

      if options[:verbose]
         puts "Volume #{i+1}/#{results.count}: [#{vol_id}]"
         puts "   State: #{state}" 
      end

      now = Time.now

      #A little cleanup on the tag string before we can parse the JSON

      tags.gsub! 'u\'','\''
      tags.gsub! '\'','"' 
      tags.gsub! /\sNone,/,'"None",' 
      tags.delete! ("\n")

      tags_hash = Hash[]

      if tags != "None"
         tags_array = JSON.parse(tags)
         tags_array.each do |x| 
            puts "     Tag: #{x['Key']} => #{x['Value']}" if options[:verbose]
            tags_hash[:"#{x['Key']}"] = "#{x['Value']}" 
         end
      end

      excludes.each do |key,array_of_values| 
         array_of_values.each do |value|
            if tags_hash.has_value?(value) || snap_id == value
               state = 'skip'
            end
         end
      end

      state = 'skip' if tags_hash[:PurgeAllow] == "false"

      case state       
      when 'skip'
 	 puts "Volume #{vol_id} was found in the exclusion list.  Skipping." if options[:verbose]
      when 'creating'
         puts "Volume #{vol_id} is being created.  Skipping." if options[:verbose]
      when 'error'      #Objects in "error" state is essentially useless
         deleteEBSResource("volume","#{vol_id}") if !options[:dryrun] 
      when 'available'  #Delete objects if they've been tagged some time ago
         ftime = now
         if tags_hash.key?(:LastUsed)
   	    if options.has_key?(:days) && (now-(Time.parse(tags_hash[:LastUsed])) > ((options[:days]).to_i)*24*3600)
               if options[:dryrun]
                  puts "On execute, would delete #{vol_id} since last used: #{tags_hash[:LastUsed]}" 
               else
	          puts "Deleting #{vol_id}: Last Used #{tags_hash[:LastUsed]}"
                  deleteEBSResource("volume","#{vol_id}")
     	       end
            end
         else           #If there's no tag, it's possibly new, so tag it 
            add_last_used_key_cmd = "aws ec2 create-tags --resources #{vol_id} --tags \"Key=LastUsed,Value=\'#{now}\'\""  
	    if options[:dryrun]
               puts "On execute, would add LastUsed tag to #{vol_id}"
            else
	       puts "Adding LastUsed=#{now} tag to #{vol_id}"
               err = IO.popen(add_last_used_key_cmd)
	       err.autoclose = true
	       sleep 5
  	    end
            puts "setting key/value with cmd: #{add_last_used_key_cmd}" if options[:verbose]
         end
      when 'in-use'
         if tags_hash.key?(:LastUsed)
            delete_last_used_key_cmd = "aws ec2 delete-tags --resources #{vol_id} --tags 'Key=LastUsed'"
            puts "Deleting key/value with cmd: #{delete_last_used_key_cmd}" if options[:verbose]
            err = IO.popen(delete_last_used_key_cmd)
	    err.autoclose = true
	    sleep 5
         end
      else
         puts "[WARNING] #{vol_id} is in UNKNOWN state" if options[:verbose]
      end
   end
end

def deleteEBSResource (type,ebs_resource) 
   if type == 'volume'
      delete_vols_cmd = "aws ec2 delete-volume --volume-id #{ebs_resource}"
      err = IO.popen(delete_vols_cmd)
   elsif type == 'snapshot'
      delete_snaps_cmd = "aws ec2 delete-snapshot --snapshot-id #{ebs_resource}"
      err = IO.popen(delete_snaps_cmd)
   end 
   err.autoclose = true
   sleep 5
end

}



