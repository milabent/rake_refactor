namespace :refactor do
  desc "Renames files and file contents"
  task :rename, [:from, :to] => :environment do |task, args|
    @from = args[:from]
    @to = args[:to]
    ops = 
      RenameFileContentOperation.find(@from, @to) + RenameFileOperation.find(@from, @to)
    puts "#{ops.length} matches found."
    execute_all = false
    ops.each_with_index do |op, index|
      puts op.to_s
      if execute_all
        op.execute
      else
        puts "Execute? [y]es [n]o [a]ll [c]ancel"
        c = $stdin.getch
        execute_all = true if c == 'a'
        break if c == 'c'
        op.execute if c == 'y' || c == 'a'
      end
    end
  end

  class RenameFileOperation
    def self.find(from, to)
      from = from.underscore
      to = to.underscore
      ops = []
      %x[ find ./app ./lib ./spec -type f | grep '#{from}' ].split.each do |file_name|
        ops << new(file_name, from, to)
      end
      ops
    end

    def initialize(file_name, from, to)
      @file_name = file_name
      @from = from
      @to = to
    end

    def execute
      %x[ #{to_s} ]
    end

    def to_s
      new_file_name = @file_name.gsub(@from, @to)
      "mkdir -p $(dirname '#{escape new_file_name}') && mv '#{escape @file_name}' '#{escape new_file_name}'"
    end

    def escape(string)
      string.gsub("'", "\\'")
    end
  end

  class RenameFileContentOperation
    def self.find(from, to)
      ops = find_for_formatted_arguments(from, to)
      ops += find_for_formatted_arguments(from.underscore, to.underscore)
      ops
    end

    def self.find_for_formatted_arguments(from, to)
      ops = []
      %x[ grep -rno '#{from}' app lib spec ].split.each do |file_name|
        file_name = file_name[0, file_name.length - from.length - 1]
        ops << new(file_name, from, to)
      end
      ops
    end

    def initialize(file_name, from, to)
      @file_name = file_name
      @from = from
      @to = to
    end

    def execute
      %x[ #{to_s} ]
    end

    def to_s
      line_number = @file_name.split(":").last
      file_name = @file_name.split(":").first
      "sed -i '#{line_number}s/#{escape(@from)}/#{escape(@to)}/g' '#{file_name}'"
    end

    def escape(string)
      string.gsub("'", "\\'").gsub("/", "\\/")
    end
  end
end
