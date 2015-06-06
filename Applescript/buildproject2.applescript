-- buildproject.applescript
-- QOLocalizableStrings

-- Created by user on 21.05.11.
-- Copyright 2011 __MyCompanyName__. All rights reserved.

-- Exapmple of call objective-c from script:
-- #import "CreatePackageAction.h"
--  @implementation CreatePackageAction
--  + (BOOL)writeDictionary:(NSDictionary *)dictionary withName:(NSString *)name
-- {
--     return [dictionary writeToFile:name atomically:YES];
-- }
-- @end

-- In a script you can then use a call method "m" of class "c" with parameters{ y,z} statement to call this method (Listing 3).
-- Listing 3  A script calling the Objective-C method

-- set descriptionRecord to
--         {|IFPkgDescriptionTitle|:packageTitle,|IFPkgDescriptionVersion|:packageVersion,
--         |IFPkgDescriptionDescription|:description,
--         |IFPkgDescriptionDeleteWarning|:deleteWarning}
-- set rootName to call method "lastPathComponent" of rootFilePath
-- set descriptionFilePath to temporaryItemsPath & rootName & "description.plist"
-- call method "writeDictionary:withName:" of class "CreatePackageAction" with parameters
--      {descriptionRecord, descriptionFilePath}
(*
property p_projectPath : "Users:oldman:Development:GenStringResources:QOLocalizableStrings.xcodeproj"
property p_target : "QOLocalizableStrings"
property p_resultCleanFileName : "Users:oldman:Documents:Temp:cleanresult.txt"
property p_resultBuildFileName : "Users:oldman:Documents:Temp:buildresult.txt"
property p_errorOfResultBuildFileName : "Users:oldman:Documents:Temp:errorbuildresult.txt"
property p_buildConfig : "Debug"
*)

(*
property p_projectPath : "Users:oldman:Development:Verpack:Verpack:Verpack.xcodeproj"
property p_target : "Verpack"
property p_resultCleanFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_cleanResult.txt"
property p_resultBuildFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_build.txt"
property p_errorOfResultBuildFileName : "Users:oldman:Documents:LocalizableStrings:Strings:LocalizableStrings:Verpack_errorsOfBuild.txt"
property p_buildConfig : "Development"
*)

on runBuildProject(projectPath, projectTarget, resultCleanFileName, resultBuildFileName, errorOfResultBuildFileName, buildConfigurationType)
	local theBuildResult
	local theCleanResult
	local theErrorResult
	set theBuildResult to {}
	set theCleanResult to {}
	set theErrorResult to {}
	
	tell application "Xcode"
		open projectPath
		tell «class proj» projectTarget
			
			(*set theBuildResult to "Analyze first.m
Analyze second.mm" as text*)
			
			try
				--
				-- set the build configuration type
				--
				set buildConfig to missing value
				set buildConfig to get «class buct» 1 whose name is buildConfigurationType
				if buildConfig = missing value then
					error "Cannot find build configuration"
				end if
				set «class abct» to buildConfig
				
				--
				-- set the target
				--
				set theTarget to missing value
				set theTarget to «class tarR» projectTarget
				if theTarget = missing value then
					error "Cannot find target"
				end if
				set «class atar» to theTarget
				
				--
				-- clean
				--
				set aResult to «event pbpsclee» with «class rpch» and «class rebl»
				set end of theCleanResult to {clean:aResult}
				
				--
				-- build
				--
				#set aResult to build using buildConfig with transcript
				#set end of theBuildResult to {|build|:aResult}
				
				#set kind to build message warning
				#set message to build message theResult
				#set theResult to build (build message)
				#set theResult to debug the active executable of myProject --new
				
			on error m
				set theErrorResult to "Exception: " & m
			end try
			#quit
		end tell
	end tell
	
	if theCleanResult is not equal to {} then
		set fileName to resultCleanFileName
		set cleanResultFile to open for access fileName with write permission
		write theCleanResult to cleanResultFile
		close access cleanResultFile
	end if
	
	if theErrorResult is not equal to {} then
		set fileName to errorOfResultBuildFileName
		set errorOfBuildResultFile to open for access fileName with write permission
		write theErrorResult to errorOfBuildResultFile
		close access errorOfBuildResultFile
	end if
	
	--
	-- parse result of building
	--
	if theBuildResult is not equal to {} then
		set theResult to missing value
		set old_delim to AppleScript's text item delimiters
		set AppleScript's text item delimiters to "
"
		set the stringsList to every text item of theBuildResult
		
		#log (stringsList count)
		
		repeat with loopVariable in stringsList
			
			#log (loopVariable)
			
			#set the wordsList to every word of loopVariable
			set AppleScript's text item delimiters to space
			set the wordsList to text items of loopVariable
			if (wordsList count) is equal to 2 then
				set firstWord to item 1 of wordsList
				
				#log ("!" & firstWord & ";")
				
				if firstWord is equal to "Analyze" then
					set secondWord to item 2 of wordsList
					#log (secondWord)
					set end of theResult to secondWord
					set end of theResult to "
"
				end if
			end if
		end repeat
		set AppleScript's text item delimiters to old_delim
		
		set fileName to resultBuildFileName
		set buildResultFile to open for access fileName with write permission
		set theResult to theResult as Unicode text
		write theBuildResult to buildResultFile
		close access buildResultFile
	end if
	return 1
end runBuildProject


#runBuildProject(p_projectPath, p_target, p_resultCleanFileName, p_resultBuildFileName, p_errorOfResultBuildFileName, p_buildConfig)
