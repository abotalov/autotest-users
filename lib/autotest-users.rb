require "autotest-users/version"

module Autotest

  class << self
    attr_accessor :email

    def configure
      yield self
    end

    def on_user_create(user); end

    def on_user_change(user); end
  end

  module Users
    def create_user(name, options = {})
      $users ||= {}
      $users[name] = ActiveSupport::HashWithIndifferentAccess.new
      set_user_data(name, options = {})
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
      end
      options.values.first
    end

    def get_user_data(name, *keys)
      user = get_user(name)
      if keys.size == 1
        user.fetch(keys.first)
      else
        keys.map { |key| user.fetch(key) }
      end
    end

    def current_user(short_name = nil)
      if short_name
        if $users.nil?
          raise "<#Autotest::Users> You should use create_user method, before 'current_user=' method."
        end
        $current_user = $users.fetch(short_name)
      end
      $current_user
    end

    def user_created?(name)
      ($users && $users[name]).nil? ? false : true
    end

    def all_users
      $users
    end

    def generate_email_for(user)
      local_part, domain_part = Autotest.email.split('@')
      user[:email] = sprintf('%s+%s%s@%s', local_part, user[:first_name].downcase, user[:last_name].downcase, domain_part)
    end
  end
end

Autotest.email = 'test@example.com'

Autotest.on_user_create do |user|
  user[:first_name] = 'First'
  user[:last_name] = 'Last'
  user[:email] = generate_email_for(user)
  user[:password] = 'password'
end

Autotest.on_user_change do |user|
  user[:full_name] = "#{user[:first_name]} #{user[:last_name]}"
end
