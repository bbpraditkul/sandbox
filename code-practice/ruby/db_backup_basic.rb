#!/usr/bin/env ruby

databases = {
    :big_client => {
        :database => 'big_client',
	:username => 'big',
	:password => 'big',
    },
    :small_client => {
	:database => 'small_client',
	:username => 'small',
	:password => 'small',
    },
    :my_client => {
	:database => 'test',
	:username => 'root',
	:password => '',
    },
}

end_of_iter = ARGV.shift

databases.each do |name,config|
    if end_of_iter.nil?
	backup_file = config[:database] + '_' + Time.now.strftime('%Y%m%d')
    else 
   	backup_file = config[:database] + '_' + end_of_iter
    end
    mysqldump = "mysqldump -u#{config[:username]} -p#{config[:password]} " + "#{config[:database]}"
    puts mysqldump
end
