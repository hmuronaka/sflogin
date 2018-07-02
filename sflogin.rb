require 'yaml'
require 'pp'
require 'optparse'
require 'pry-byebug'

ACCOUNT_FILE = File.expand_path('~/.sfaccount.yaml')

def load_accounts
  accounts = YAML.load(File.read(ACCOUNT_FILE))
end

def print_account(accounts)
  accounts.each_with_index do | account,idx |
    puts "#{idx}: #{account["username"]} #{account["password"]} #{account["description"]}"
  end
end

def read_idx()
  print ">"
  result = -1
  while line = STDIN.readline
    if line =~ /([\d]+)/
      result = $1.to_i
      break
    end
  end
  return result
end

def get_account(accounts, initVal)
  display_accounts = accounts
  result = nil
  if initVal.nil?
    print_account display_accounts 
    print ">"
  end

  while true
    line = initVal || STDIN.readline.chop
    initVal = nil

    if not line
      break
    end

    if line =~ /^([\d]+)$/
      result = display_accounts[$1.to_i]
      break
    else
      display_accounts = display_accounts.select do |elem|
        elem["username"].include?(line)
      end

      if display_accounts.empty?
        display_accounts = accounts
      elsif display_accounts.size == 1
        result = display_accounts[0]
        break
      else
        print_account display_accounts
        print ">"
      end
    end
  end
  return result
 
end

def encoded_str(str)
  str.gsub(/\+/, '%2B')
end

def get_url(account)
  "https://#{account["is_sandbox"] ? "test" : "login"}.salesforce.com?un=#{encoded_str(account["username"])}&pw=#{encoded_str(account["password"])}"
end

def open_url(url)
  `open "#{url}"`
end

def main
  accounts = load_accounts
  # print_account accounts
  account = get_account(accounts, ARGV[0])
  url = get_url(account)
  puts url
  open_url(url)
end

main


