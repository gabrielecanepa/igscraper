class Logger
  class << self
    def log_message(message)
      puts message
    end

    def log_recursive_message(message)
      print "#{message}\r"
    end

    def log_success_message(message)
      puts "\e[32m#{message}\e[0m"
    end

    def log_error_message(message)
      puts "\e[31m#{message}\e[0m"
    end

    def log_break
      puts ""
    end
  end
end
