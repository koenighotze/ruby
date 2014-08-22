#!/usr/bin/ruby -w
require 'net/http'

CACHE_FILE="/c/java2/bin/whois.cache"

username = ARGV[0] or raise "Please provide a user!"
showPic = ARGV[1] || nil

class UserData 
    attr_reader :name, :uid, :mail_address, :phone_number
    
    def initialize(aName, aUid, aMailAddress, aPhoneNumber)
        aName.nil? and raise "aName"
        aUid.nil? and raise "anUid"
        aMailAddress.nil? and raise "aMailAddress"
        aPhoneNumber.nil? and raise "aPhoneNumber"

        @name = aName
        @uid = aUid
        @mail_address = aMailAddress
        @phone_number = aPhoneNumber
    end

    def UserData.createFrom(aString) 
        aString.nil? and raise "aString"
        tmpFields = aString.split(%r{\s*,\s*})
        tmpFields.size == 4 or raise "Cannot parse #{aString}"
        return UserData.new(tmpFields[0], tmpFields[1], tmpFields[2], tmpFields[3])
    end

    def to_s
        return "Name: #{@name} UID: #{@uid} Mail: #{@mail_address} Phone: #{@phone_number}"
    end
end

def gotMultipleMatches(body)
    got = false
    body.each_line { |line|
      if line =~ %r{<title>.*entries match.*}i
        got = true
      end
    }
    return got
end

def showPicInExplorer(anUid)
    ie = nil
    begin
      require 'win32ole'
      ie = WIN32OLE.new('InternetExplorer.Application')
      ie.visible = true
      ie['AddressBar'] = false
      ie['MenuBar'] = false
      ie['StatusBar'] = false
      ie['ToolBar'] = false
      ie['Width'] = 200
      ie['Height'] = 200
      ie.navigate("URL?uid=#{anUid}")
    rescue
        puts "Cannot show picture for uid: #{anUid}!"
    end
end

def getFromWeb(anUserName)
    anUserName.nil? and raise "anUserName"
    username = anUserName.sub(%r{\s+}, "%20")
    response = Net::HTTP.get_response(URI.parse("http://www.intdus.retail-sc.com/cab/lqhtml.cgi?fullsearch=#{username}")) 
    body = response.body
    body.nil? and  raise "No response received!"
    tmpName = ""
    tmpUid = ""
    tmpMailAddress = ""
    tmpPhone = ""
    tmpUserData = nil
    if gotMultipleMatches(body)
        puts "Multiple matches found:"
        body.each_line { |line|
          line =~ %r{<td class="sn"><a[^>]+uid=([^"]+)[^>]+>([^<]+)</a></td>$}i or next
          tmpName, tmpUid = $2, $1
          if tmpName and tmpUid 
              puts "  #{tmpUid} => #{tmpName}" 
              tmpUid = nil
              tmpName = nil
          end
        }
        return nil
    end

    
    body.each_line { |line|
      line =~ %r{row-(cn|telephonenumber|uid|maillocaladdress).*<td[^>]*>([^<>]*)</td>$}i or next
      category,value = $1, $2
      case category
      when "cn"
          tmpName = value
      when "telephonenumber"
          tmpPhone = value
      when "uid"
          tmpUid = value
      when "maillocaladdress"
          tmpMailAddress = value
      else 
          raise "Unknown category #{category}"
      end

      tmpUserData = UserData.new(tmpName, tmpUid, tmpMailAddress, tmpPhone)
    }

    tmpUserData.nil? and raise "User #{anUserName} not found!"
    return tmpUserData
end

def getFromCache(aFileName, anUserName) 
    anUserName.nil? and raise "anUserName"
    aFileName.nil? and raise "aFileName"

    file = File.new(aFileName, "a+")
    begin
        tmpUser = nil
        file.each { |line|  
            line =~ %r{#{anUserName}\s*,} or line =~ %r{[^,]+,#{anUserName}\s*,} or next
            tmpUser = UserData.createFrom(line)
            break
        }
        return tmpUser
    ensure
          file.close
    end
end

def storeInCache(aFileName, anUserData) 
    anUserData.nil? and raise "anUserData"
    aFileName.nil? and raise "aFileName"
    file = File.new(aFileName, "a+")
    begin
        file.puts("#{anUserData.name},#{anUserData.uid},#{anUserData.mail_address},#{anUserData.phone_number}")
    ensure
          file.close
    end
end

tmpUserData = getFromCache(CACHE_FILE, username)
if tmpUserData.nil? 
    tmpUserData = getFromWeb(username) 
    storeInCache(CACHE_FILE, tmpUserData) if tmpUserData
end

if tmpUserData
    showPicInExplorer(tmpUserData.uid) if showPic
    puts tmpUserData
end

