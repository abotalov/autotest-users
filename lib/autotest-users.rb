require "autotest-users/version"

module Autotest
  module Users
    class << self
      attr_accessor :email
      attr_reader :post_create_block, :post_change_block

      def configure
        yield self
      end

      def on_user_create(&block)
        @post_create_block = block
      end

      def on_user_change(&block)
        @post_change_block = block
      end

      def generate_email_for(user)
        local_part, domain_part = email.split('@')
        user[:email] = sprintf('%s+%s%s@%s', local_part, user[:first_name].downcase, user[:last_name].downcase, domain_part)
      end
    end
  end

    def create_user(name, options = {})
      $users ||= {}
      $users[name] = ActiveSupport::HashWithIndifferentAccess.new
      Autotest::Users.post_create_block.call(user)
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
      Autotest::Users.post_change_block.call(user)
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
  end
end

Autotest::Users.email = 'test@example.com'

Autotest::Users.on_user_create do |user|
  user[:first_name] = 'First'
  user[:last_name] = 'Last'
  user[:email] = Autotest::Users.generate_email_for(user)
  user[:password] = 'password'
end

Autotest::Users.on_user_change do |user|
  user[:full_name] = "#{user[:first_name]} #{user[:last_name]}"
end
