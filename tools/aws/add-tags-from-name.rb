#! /usr/bin/env ruby
require 'optparse'
require 'rubygems'
require 'json'
require 'time'

options = {}
OptionParser.new do |opts|
   opts.banner = "Usage: add-tags-from-name [options]"
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

parseNameTag(options)
#addTags()

BEGIN { 

def parseNameTag(options)
   all_instances_cmd = "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags]' --region us-west-1 --output text"

   all_instances = `#{all_instances_cmd}`.split("\n")

#   puts "Instance Found: #{all_instances.count} instances" if options[:verbose]

   printf "%20s %20s %20s\n", "Product", "Environment", "Component"
   all_instance_names = Hash.new

   all_instances.each_with_index do |line|

      str1, str2 = line.split("\t")
      if str1 =~ /^(i-\S+)/
         instance_id = $1
      elsif str1 =~ /^Name/
         if str2 =~ /(\S+)/
            instance_name = $1
         end
      else 
         next
      end

      if instance_id != '' && instance_name != ''
         p "#{instance_id} #{instance_name}"
         all_instance_names[instance_id] = instance_name
      end
      
   end

   all_instance_names.each do |key|
      p key
   end

=begin      
      if options[:verbose]
#         puts "Tag #{i+1}/#{all_instances.count}: #{instance_id}"
         
         str_part_1, str_part_2, str_part_3 = instance_name.split /-/

         product = str_part_1

         if (str_part_2 =~ /((stg)|(prd)|(tst))\d*/i)
            environment = $1
	    component = str_part_3
         elsif (str_part_3 =~ /((stg)|(prd)|(tst))\d*/i)
	    environment = $1
	    component = str_part_2
         end    
         printf "%20s %20s %20s\n", product, environment, component

         puts "Creating Tags for instance_id: #{instance_id}"
         puts "Product = #{product}, Environment = #{environment}" 

         #add_tags_cmd "aws ec2 create-tags --resources i-8644d94c --tags 'Key="Environment",Value=stg'
      end
   end
=end

end
}



