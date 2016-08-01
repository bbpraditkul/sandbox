#! /usr/bin/env ruby
require 'optparse'
require 'json'
require 'time'

#********************************************************
# The following script deletes EBS Volumes/Snapshots
# that are:
# 1) volumes tags are older than a user defined day count
#    and are marked in "available"/"error" status
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

options = {}
OptionParser.new do |opts|
   opts.banner = "Usage: view-ebs-entities [options]"
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

BEGIN { 

#**********************************
# viewVols - Manage EBS Volumes
#
   available_vols_cmd = "aws ec2 describe-volumes --output text --query \"Volumes[*].[VolumeId,SnapshotId,CreateTime,Size,State,Tags]\""

   results = `#{available_vols_cmd}`.split("\n")

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

      case state       
      when 'in-use'
         if tags_hash.key?(:LastUsed)
            puts "Listing key/value with cmd: #{delete_last_used_key_cmd}" if options[:verbose]
         end
      else
         puts "[WARNING] #{vol_id} is in UNKNOWN state" if options[:verbose]
      end
   end
end




