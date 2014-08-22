#!ruby

require "rexml/document"
include REXML

DEBUG = true

def debug(aMsg) 
    return unless DEBUG
    $stderr.puts "DEBUG: #{aMsg}"
end
def error(aMsg) 
    $stderr.puts "ERROR: #{aMsg}"
end


class Dependency 
    attr_reader :artifactId, :version
    def initialize(anArtifactId, aVersion)
        anArtifactId.nil? and raise "anArtifactId"
        aVersion.nil? and raise "aVersion"

        @artifactId = anArtifactId
        @version = aVersion
    end
    
    def Dependency.createFrom(aNode)
        aNode.nil? and raise "aNode"
        
        tmpGroupId = XPath.first(aNode, "groupId/text()")
        tmpArtifactId = XPath.first(aNode, "artifactId/text()") 
        tmpVersion = XPath.first(aNode, "version/text()") 

        tmpArtifactId.nil? and raise "Artifact id is null in dependency #{aNode}"
        tmpVersion.nil? and raise "Version is null in dependency #{aNode}"
     
        return new(tmpArtifactId, tmpVersion)
    end

    def to_s
        return "#{@artifactId}-#{@version}"
    end
end

class Project
    attr_reader :artifactId

    @@PROJECTS = Hash.new()
    
    def initialize(aDir, anArtifactName, aProjectXML)
        @dir = aDir
        @artifactId = anArtifactName
        @projectXML = aProjectXML
    end
    
    def Project.createFromFile(aDir, aFileName)
        aFileName.nil? and raise "aFileName"
        aDir.nil? and raise "aDir"

        
        @@PROJECTS.has_key?("#{aDir}/#{aFileName}") and return @@PROJECTS["#{aDir}/#{aFileName}"]

        tmpProjectXML = Document.new File.new("#{aDir}/#{aFileName}")
        tmpArtifactName = Project.getArtifactName(tmpProjectXML)

        tmpProj = Project.new(aDir, tmpArtifactName, tmpProjectXML)
        @@PROJECTS["#{aDir}/#{aFileName}"] = tmpProj
        return tmpProj
    end

    def Project.getArtifactName(aProjectXML)
        aProjectXML.nil? and raise "aProjectXML"

        tmpId = XPath.first(aProjectXML, "/project/id/text()")
        return "#{tmpId}"
    end

    def getDependendJarNames()
        tmpDependendJarNames = Array.new()
        XPath.each(@projectXML, "/project/dependencies/dependency") { |aNode|
            tmpDependendJarNames.push(Dependency.createFrom(aNode))
        }

        return tmpDependendJarNames
    end

    def dependencies() 
        return getCompleteDependencies(@dir, "project.xml")
    end
    
    def extendedPOMs() 
        XPath.each(@projectXML, "/project/extend/text()") { |aNode|
            yield(aNode)
        }
    end
    
    def getCompleteDependencies(aDir, aFileName)
        tmpProject = Project.createFromFile(aDir, aFileName)
        tmpDeps = tmpProject.getDependendJarNames()

        tmpProject.extendedPOMs { |aPOMFileName|
            tmpExtended = Project.createFromFile(aDir, aPOMFileName)
            tmpExtended.getCompleteDependencies(aDir, aPOMFileName).each { |aDep|
                tmpDeps.push(aDep)
            }
        }

        return tmpDeps
    end

    def getBranchName()
        tmpOldDir = Dir.pwd()
        begin
            Dir.chdir(@dir)
            tmpBranch = "" 
            IO.popen("/c/Program\\ Files/TortoiseCVS/cvs status project.xml").each { |aLine|
                tmpBranch = $1 and next if (aLine =~ %r{Sticky Tag:\s+([a-z0-9_\-]+)}i)
            }
            debug("Branch for #{@dir} is #{tmpBranch}")
            return tmpBranch
        ensure
            Dir.chdir(tmpOldDir)
        end
    end

    def defines?(aDependency)
        return @artifactId =~ %r{#{aDependency.artifactId}} 
    end
end


BRANCH_DIR_CACHE = Hash.new()
def getBranchForProjectXml(aDir) 
    aDir.nil? and raise "aDir"
    
    BRANCH_DIR_CACHE.has_key?(aDir) and return BRANCH_DIR_CACHE[aDir]
    File.exists?("#{aDir}/project.xml") or return nil

    tmpProject = Project.createFromFile(aDir, "project.xml")
    tmpBranch = tmpProject.getBranchName()
    BRANCH_DIR_CACHE[aDir] = tmpBranch
end

def doLogin(aPassword)
    tmpOldDir = Dir.pwd()
    Dir.glob("*").each { |aDir|
        begin
            next unless FileTest.directory?(aDir)
            Dir.chdir(aDir)
            next unless FileTest.exists?("CVS")
            system("cvs login -p #{aPassword}") or raise "Cannot login #{$?}"
        ensure
            Dir.chdir(tmpOldDir)
        end
    }
end

def getDirsContainingDependency(aDependency) 
    aDependency.nil? and raise "aDependency"
    
    tmpDirs = Array.new
    debug("Search dirs containing #{aDependency.artifactId}")
    Dir.glob("*").each { |aDir|
        next unless FileTest.exists?("#{aDir}/project.xml") 

        tmpProject = Project.createFromFile(aDir, "project.xml")
        tmpProject.defines?(aDependency)  and tmpDirs.push(aDir)
    }
    tmpDirs.each {|a| debug("    => #{a}") }
    debug("...finished searching #{aDependency.artifactId}")

    return tmpDirs
end

@projectDirs = Array.new()
ARGV.each { |arg|
    FileTest.directory?(arg) or next
    FileTest.exists?("#{arg}/.project") or next
    FileTest.exists?("#{arg}/project.xml") or next
    @projectDirs.push(arg)
}


buildProperties = Hash.new()
@projectDirs.each { |aDir|
    tmpProject = Project.createFromFile(aDir, "project.xml")
    tmpProject.dependencies.each { |aDependency| 
        debug("Checking #{aDependency}...")
        tmpDirs = getDirsContainingDependency(aDependency)

        next if tmpDirs.empty? 

        tmpMapToProjectDir = nil
        if tmpDirs.size > 1 
            tmpVersion = aDependency.version.to_s.sub("-SNAPSHOT", "")
            tmpDirs.each { |aDirName| 
                tmpBranch = getBranchForProjectXml(aDirName)
                if tmpBranch =~ %r{#{tmpVersion}$} 
                    tmpMapToProjectDir = aDirName
                end
            }
        end
        tmpMapToProjectDir ||= tmpDirs[0]
        buildProperties[aDependency.artifactId] = tmpMapToProjectDir
    }
}

buildProperties.each_pair { |k, v| puts "#{k}:#{v}"}
