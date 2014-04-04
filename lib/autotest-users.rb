require "autotest-users/version"

module Autotest

  class << self
    attr_accessor :email, :password

    def configure
      yield self
    end
  end

  module Users
    def create_user(name)
      require "randexp"

      $users ||= {}
      $users[name] = ActiveSupport::HashWithIndifferentAccess.new

      first_name = /[:first_name:]/.gen
      last_name = /[:last_name:]/.gen
      first_name.gsub!("'",'')
      last_name.gsub!("'",'')

      $users[name][:first_name] = first_name
      $users[name][:last_name] = last_name
      $users[name][:full_name] = "#{first_name} #{last_name}"
      email = Autotest.email.split('@')
      $users[name][:email] = "%s+%s%s@%s" % [email[0], first_name.downcase, last_name.downcase, email[1]]
      $users[name][:password] = Autotest.password

      $users[name]
    end

    def get_user(name)
      if $users.nil?
        raise "<#Autotest::Users> No one user is created"
      end
      $users.fetch(name)
    end

    def set_user_data(name, options = {})
      user = get_user(name)
      options.with_indifferent_access.each do |key, value|
        user[key] = value
        if %w(first_name last_name).include?(key)
          user[:full_name] = "#{user[:first_name]} #{user[:last_name]}"
        end
      end
      options.values.first
    end

    def get_user_data(name, key)
      user = get_user(name)
      user.fetch(key)
    end

    def current_user(short_name = nil)
      if short_name
        if $users.nil?
          raise "<#Autotest::Users> You should use create_user method, before 'current_user=' method."
        end
        $current_user = $users[short_name]
      end
      $current_user
    end

    def user_created?(name)
      ($users && $users[name]).nil? ? false : true
    end
    
    def all_users
      $users
    end

  end
end

Autotest.configure do |config|
  config.email = 'email@example.com'
  config.password = 'password'
end
