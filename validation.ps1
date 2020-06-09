#####################################################################

[int]$Status_FIELDID = 19
[int]$UID_FIELDID = 20


#CONFIRM THE FOLLOWING PROJECTID/FIELDID
[int]$Header_Reference_FIELDID = 1
[int]$Header_Supplier_FIELDID = 3
[int]$Header_TotalExGST_FIELDID = 10
[int]$Header_TaxCode_FIELDID = 11
[int]$Header_TotalGST_FIELDID = 12
[int]$Header_TotalIncGST_FIELDID = 13

[int]$Line_Quantity_FIELDID = 6
[int]$Line_Price_FIELDID = 7
[int]$Line_GLCode_FIELDID = 9
[int]$Line_LineExGST_FIELDID = 10
[int]$Line_TaxCode_FIELDID = 11
[int]$Line_LineGST_FIELDID = 12
[int]$Line_LineIncGST_FIELDID = 13

[int]$Parameters_ProjectID = 1
[int]$Parameters_ContextProject = 1
[int]$Parameters_ForeignProject = 2
[int]$Parameters_ParamName = 3
[int]$Parameters_ParamDesc = 4
[int]$Parameters_Value1 = 5
[int]$Parameters_Value2 = 6
[int]$Parameters_Value3 = 7
[int]$Parameters_Value4 = 8
[int]$Parameters_Value5 = 9
[int]$Parameters_Value6 = 10
[int]$Parameters_Status = 19
[int]$Parameters_UID = 20

[int]$TaxCode_ProjectID = 18
[int]$TaxCode_TaxCode = 1
[int]$TaxCode_TaxPerc = 3



#####################################################################
[int]$Parameter_ContextProject_FieldID = 1
[int]$Parameter_ParameterName_FieldID = 3
[int]$Parameter_Status_FieldID = 19
[int]$AP_Invoices_Status = 19

#####################################################################
#####################################################################

function UpdateFileNotes
{
	param([string]$Message, [int] $LOGLEVEL)
	
	#Log Level 0 = NO MESSAGES
	#Log Level 1 = ERROR messages
	#Log Level 2 = USER messages
	#Log Level 3 = USER DETAIL messages
	#log level 10 = DETAIL messages
	#Log Level 99 = all messages

	if ($LOGLEVEL -le 10)
	{
		$today = Get-Date
		$SS = [String]$today.Second
		$MM = [String]$today.Minute
		$HH = [String]$today.Hour
		$D = [String]$today.day
		$M = [String]$today.Month
		$Y = [String]$today.Year

		#PREPEND
		$context.File.Notes = $D + "/" + $M + "/" + $Y + " " + $HH + ":" + $MM + ":" + $SS +"-" + $Message  + "`n" + $context.File.Notes
		#APPEND
		#$context.File.Notes += $D + "/" + $M + "/" + $Y + " " + $HH + ":" + $MM + ":" + $SS +"-" + $Message  + "`n"
		$Context.File.Save() | out-null
	}
	return "done"
}

#####################################################################

function UpdateDocNotes
{
	param([string]$Message, [int] $LOGLEVEL)
	
	#Log Level 0 = NO MESSAGES
	#Log Level 1 = ERROR messages
	#Log Level 2 = USER messages
	#Log Level 3 = USER DETAIL messages
	#log level 10 = DETAIL messages
	#Log Level 99 = all messages

	if ($LOGLEVEL -le 10)
	{
		$today = Get-Date
		$SS = [String]$today.Second
		$MM = [String]$today.Minute
		$HH = [String]$today.Hour
		$D = [String]$today.day
		$M = [String]$today.Month
		$Y = [String]$today.Year

		#add a zero if the month value is a single digit
		if ($M -match '\d{2}')
		{
			$M = $M
		}
		else
		{
			$M = "0" + $M

		}
		#add a zero if the minute value is a single digit
		if ($MM -match '\d{2}')
		{
			$MM = $MM
		}
		else
		{
			$MM = "0" + $MM

		}
		#add a zero if the second value is a single digit
		if ($SS -match '\d{2}')
		{
			$SS = $SS
		}
		else
		{
			$SS = "0" + $SS

		}

		[String]$AP = "AM"
		if ([int]$HH -ge 12)
		{
			[String]$AP = "PM"
			if ([int]$HH -ge 13)
			{
				[string]$HH = [int]$HH - 12
			}
		}
		#PREPEND
		$Context.Document.Notes = "`n" + $D + "/" + $M + "/" + $Y + " " + $HH + ":" + $MM + ":" + $SS + " " + $AP + " // " + $Message + $context.Document.Notes
		#APPEND
		#$Context.Document.Notes += $D + "/" + $M + "/" + $Y + " " + $HH + ":" + $MM + ":" + $SS +" " + $AP + " // " + $Message + "`n"
		$Context.Document.Save() | out-null
	}
	return "done"
}

#####################################################################

function GetHFieldList($ParamHeaderIDs)
{
	#This script returns a list of the header fields from its parameter
	UpdateDocNotes "Running PS GetHFieldList." 10 | Out-null

	#Set status flag and exception flag
	$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	
	#Access the current project name
	$projectName = $Context.Project.Name
	UpdateDocNotes "projectName $projectName" 10 | Out-null
	
	#Access the number of fields setup on the current project
	$Context.Project.Fields.Fill() | Out-Null
	$fieldcount = $Context.Project.Fields.Count
	UpdateDocNotes "The fieldcount is the numebr of fields setup for the project $fieldcount" 10 | Out-null
	
		
	#Loop through all fields of the current project and store field name in an array
	if ($fieldcount -eq 0) {
		UpdateDocNotes "projectName Project has not been configured with any fields. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - NO FIELDS"
	}
	else {
		
		UpdateDocNotes "ParamHeaderIDs: $ParamHeaderIDs" 10 | Out-null
		for ($i=0; $i -lt $fieldcount; $i++)
		{
			$Context.Project.Fields.Fill() | Out-Null
			$HeaderFieldID = $Context.Project.Fields[$i].Number
			UpdateDocNotes "HeaderFieldID: $HeaderFieldID" 10 | Out-null
			if($HeaderFieldID -in $ParamHeaderIDs) {
				$fieldname = $Context.Project.Fields[$i]
				UpdateDocNotes "fieldname variable will return the name of the first field = $fieldname" 10 | Out-null
				[string[]]$HeaderFieldArray = $HeaderFieldArray + $fieldname
			}
		}
	}
	UpdateDocNotes "GetH HeaderFieldArray: $HeaderFieldArray" 10 | Out-null


	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS GetHFieldList." 10 | Out-null
	return $HeaderFieldArray
}

#####################################################################

function GetLIFieldList($ParamIDs)
{
	#This script returns a list of the line item fields from its parameter
	UpdateDocNotes "Running PS GetLIFieldList." 10 | Out-null


	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	UpdateDocNotes "FLAG: $FLAG" 10 | Out-null
	$Context.Project.Fields.Fill() | Out-Null
	
	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	#If ED, continue
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'GetLIFieldList' #Filter on function name
		$PARAM.Fill()

								UpdateDocNotes $Context.File.ProjectID  10 | Out-null
								UpdateDocNotes $PARAM.Count   10 | Out-null

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {

					#Access the number of fields setup on the current project
					$Context.Project.Fields.Fill() | Out-Null
					$CurrentProject = $Context.Project.ProjectID
					UpdateDocNotes "CurrentProject: $CurrentProject" 10 | Out-Null
					$CurrentLiProject = $Context.File.ProjectID
					UpdateDocNotes "CurrentLiProject: $CurrentLiProject" 10 | Out-Null
					$fieldcount = $Context.File.Field.Count
					UpdateDocNotes "The fieldcount is the number of fields setup for the project $fieldcount" 10 | Out-Null
	
		
					#Loop through all fields of the current project and store field name in an array
					if ($fieldcount -eq 0) {
					UpdateDocNotes "projectName Project has not been configured with any fields. Please contact the support team." 2 | Out-null
					$FLAG = "EXCEPTION - NO FIELDS"
					}
					else {
					$Context.File.LineItems.Fill() | Out-Null
					$Lifieldcount = $Context.File.LineItems.Count
					UpdateDocNotes "The Lifieldcount is the numebr of fields setup for the project $Lifieldcount" 10 | Out-Null

					if ($Context.File.LineItems.Count -gt 0) 
					{
					$lifile = $Context.File.LineItems[0]
					$liproject = $Context.Business.GetObjectItem(2,$lifile.ProjectID)
					$liproject.Fields.Fill() | Out-Null
			
					foreach($pr in $liproject.Fields)
					{  
					$prNumber = $pr.Number
					$prName = $pr.Name
					UpdateDocNotes "prNumber $prNumber prName $prName"  2 | out-null
					if ($prNumber -in $ParamIDs) {
						[string[]]$LiFieldNameArray = $LiFieldNameArray + $prName
						#$myArray -join ","    
						#$LineNameAndID = $prNumber -join "," -join $prName
						#[string[]]$LiFieldNameArray = $LiFieldNameArray + $LineNameAndID
						}
					}
					}
					}
				}
			}


	#Assign status flag
	UpdateDocNotes "LiFieldNameArray $LiFieldNameArray"  10 | out-null 
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS GetLIFieldList." 10 | Out-null
	return $LiFieldNameArray
} 

#####################################################################

function GetLIFieldListOriginal($ParamIDs)
{
	#This script returns a list of the line item fields from its parameter
	UpdateDocNotes "Running PS GetLIFieldList." 10 | Out-null

	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	UpdateDocNotes "FLAG: $FLAG" 10 | Out-null
	$Context.Project.Fields.Fill() | Out-Null
	
	

	#Access the number of fields setup on the current project
	$Context.Project.Fields.Fill() | Out-Null
	$CurrentProject = $Context.Project.ProjectID
	UpdateDocNotes "CurrentProject: $CurrentProject" 10 | Out-Null
	$CurrentLiProject = $Context.File.ProjectID
	UpdateDocNotes "CurrentLiProject: $CurrentLiProject" 10 | Out-Null
	$fieldcount = $Context.File.Field.Count
	UpdateDocNotes "The fieldcount is the numebr of fields setup for the project $fieldcount" 10 | Out-Null
	
		
	#Loop through all fields of the current project and store field name in an array
	if ($fieldcount -eq 0) {
		UpdateDocNotes "projectName Project has not been configured with any fields. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - NO FIELDS"
	}
	else {
		$Context.File.LineItems.Fill() | Out-Null
		$Lifieldcount = $Context.File.LineItems.Count
		UpdateDocNotes "The Lifieldcount is the numebr of fields setup for the project $Lifieldcount" 10 | Out-Null

		if ($Context.File.LineItems.Count -gt 0) 
		{
			$lifile = $Context.File.LineItems[0]
			$liproject = $Context.Business.GetObjectItem(2,$lifile.ProjectID)
			$liproject.Fields.Fill() | Out-Null
			
			foreach($pr in $liproject.Fields)
			{  
				$prNumber = $pr.Number
				$prName = $pr.Name
				UpdateDocNotes "prNumber $prNumber prName $prName"  2 | out-null
				if ($prNumber -in $ParamIDs) {
					[string[]]$LiFieldNameArray = $LiFieldNameArray + $prName
					#$myArray -join ","    
					#$LineNameAndID = $prNumber -join "," -join $prName
					#[string[]]$LiFieldNameArray = $LiFieldNameArray + $LineNameAndID
				}
			}
		}
	}


	#Assign status flag
	UpdateDocNotes "LiFieldNameArray $LiFieldNameArray"  10 | out-null 
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS GetLIFieldList." 10 | Out-null
	return $LiFieldNameArray
} 

#####################################################################
function CalculateMissingTotal
{
	# This script will calculate header data fields if header is missing

	UpdateDocNotes "Running PS CalculateMissingTotal." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	#If ED, continue
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'CalculateMissingTotal' #Filter on function name
		$PARAM.Fill()

								UpdateDocNotes $Context.File.ProjectID  10 | Out-null
								UpdateDocNotes $PARAM.Count   10 | Out-null

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "CalculateMissingTotal is disabled." 10 | Out-null
			}
			#If parameter is enabled, continue
			else {
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				#Only run script if ED meets Value1 criteria, or if script is set to run no matter where in the workflow the doc is
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					#CHANGE THE BELOW FIELDS TO MATCH PARAMS ((wont be needing to change if we meet standard field numbers))
					[String]$NET = $Context.File.Field[$Header_TotalExGST_FIELDID]
					[String]$GST = $Context.File.Field[$Header_TotalGST_FIELDID]
					[String]$GROSS = $Context.File.Field[$Header_TotalIncGST_FIELDID]
					
					#Calculate Invoice Gross if blank, only if Ex-Gst and Gst are present
					if(([String]$NET -ne '') -and ([String]$GST -ne '') -and ([String]$GROSS -eq '')) {
						[double]$GROSS = [math]::Round(([double]$GST + [double]$NET),2)
						UpdateDocNotes "Total Inc GST was calculated as it was missing." 2 | Out-null
					}

					#Calculate Invoice Net if blank, only if Total and Gst are present
					if(([String]$NET -eq '') -and ([String]$GST -ne '') -and ([String]$GROSS -ne '')) {
						[double]$NET = [math]::Round(([double]$GROSS - [double]$GST),2)
						UpdateDocNotes "Total Ex GST was calculated as it was missing." 2 | Out-null
					}

					#Calculate Invoice GST if blank, only if Total and Ex-Gst are present
					if(([String]$NET -ne '') -and ([String]$GST -eq '') -and ([String]$GROSS -ne '')) {
						[double]$GST = [math]::Round(([double]$GROSS - [double]$NET),2)
						UpdateDocNotes "Total GST was calculated as it was missing." 2 | Out-null
					}

					#CHANGE THE BELOW FIELDS TO MATCH PARAMS
					$Context.File.Field[$Header_TotalExGST_FIELDID] = $NET 
					$Context.File.Field[$Header_TotalGST_FIELDID] = $GST
					$Context.File.Field[$Header_TotalIncGST_FIELDID] = $GROSS 
				}
				else {
					#Debug
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS CalculateMissingTotal." 10 | Out-null
	return "done"
}

#####################################################################

function HeaderBlankCheck
{
	#Checks to see if any required fields are blank
	UpdateDocNotes "Running PS HeaderBlankCheck." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill() | Out-Null
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'HeaderBlankCheck' #Filter on function name
		$PARAM.Fill() | Out-Null
													
								UpdateDocNotes $Context.File.ProjectID  10 | Out-null
								UpdateDocNotes $PARAM.Count   10 | Out-null
								
		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "HeaderBlankCheck is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					#split fieldlist
					$FieldList = $PARAM.Field[$Parameters_Value2]
					[string[]]$FieldArray = [string]$FieldList -split ","
					[int]$FieldCount = $FieldArray.Length

					[string[]]$FieldNames = GetHFieldList($FieldArray)
					UpdateDocNotes "FieldNames: $FieldNames" 10 | Out-null
					

					#Ensure there is at least one field to validate
					if ($FieldCount -eq 0) 
					{
						UpdateDocNotes "No fields listed for validation. Please contact the support team." 2 | Out-null
						$FLAG = "EXCEPTION - PARAMETERS"
					}
					else {
						UpdateDocNotes "Field Count = $FieldCount" 10 | Out-null
						
						#Validate all fields are acceptable
						for ($i = 0; $i -lt $FieldCount; $i++) {
							$temp = $FieldArray[$i]
							UpdateDocNotes "element $i = $temp" 10 | Out-null
						}
						
						
						#Validate all fields are acceptable
						for ($i = 0; $i -lt $FieldCount; $i++) {
							
							try {
								#get field number and name from fieldlist
								[int]$FieldNumber = $FieldArray[$i]
								UpdateDocNotes "FieldNumber = $FieldNumber" 10 | Out-null
								#$FieldName = $FieldNames[$FieldNumber]
								$FieldName = $FieldNames[$i]
								UpdateDocNotes "FieldName = $FieldName" 10 | Out-null
								
							}
							catch {
								#error: param is wrong
								UpdateDocNotes "A field listed in HeaderBlankCheck parameters is incorrect. Please contact support." 2 | Out-null
								$FLAG = "EXCEPTION - PARAMETERS"
							}
							
							#if field contents is blank then exception else continue
							if ($Context.File.Field[$FieldNumber] -eq '') {
								UpdateDocNotes "$FieldName is blank, please populate this field." 2 | Out-null
								$FLAG = "EXCEPTION - BLANK FIELD"
								$EXCEPTION = "YES"
							}
							else {
								UpdateDocNotes "$FieldName is populated." 10 | Out-null
							}

						}
						
						if ($EXCEPTION -eq "NO") {
							UpdateDocNotes "All fields populated." 10 | Out-null
						}
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS HeaderBlankCheck." 10 | Out-null
	return "done"
}


#####################################################################


function HeaderAmountValidation
{
	#Checks to see if header net + gst = gross
	UpdateDocNotes "Running PS HeaderAmountValidation." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'HeaderAmountValidation' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "HeaderAmountValidation is disabled." 10 | Out-null
			}
			else {
				try {
					#Get values from PARAM project 
					
					# Value 2 contains Field Ids in the following order (ExGST,GST,IncGST_ExGST,GST,IncGST) for Context_Foreign projects. 
					[string[]]$KeyFields = $PARAM.Field[$Parameters_Value2] -split "_"
					[string[]]$SourceKeyFields = $KeyFields[0] -split ","
					[string[]]$ForeignKeyFields = $KeyFields[1] -split ","
					
					#Set ExGST,GST and IncGST FieldIDs from Param project for Header and Line
					[int]$Header_TotalExGST_FIELDID = $SourceKeyFields[0]
					[int]$Header_TotalGST_FIELDID = $SourceKeyFields[1]
					[int]$Header_TotalIncGST_FIELDID = $SourceKeyFields[2]
												
					$Count_SourceKeyFields = $SourceKeyFields.Count
					$Count_ForeignKeyFields = $ForeignKeyFields.Count

					UpdateDocNotes "SourceKeyFields Value: $SourceKeyFields" 10 | Out-null
					UpdateDocNotes "Count_SourceKeyFields: $Count_SourceKeyFields" 10 | Out-null
					UpdateDocNotes "ForeignKeyFields Values: $ForeignKeyFields" 10 | Out-null
					UpdateDocNotes "Count_ForeignKeyFields: $Count_ForeignKeyFields" 10 | Out-null

					$BlankCheck = "FALSE"
					$BlankCheck = ArrayBlankCheck($SourceKeyFields)
					$BlankCheck = ArrayBlankCheck($ForeignKeyFields)

					# Value 3 contains the variance amount in cents (e.g. 1 cent, 2 cent)
					[string]$NumDecimals = $PARAM.Field[$Parameters_Value3]
					
					#Check if Value 3 is an integer
					$Value3IsInt = $NumDecimals -match "^\d+$"
					UpdateDocNotes "Value3IsInt: $Value3IsInt" 10 | Out-null
					UpdateDocNotes "NumDecimals: $NumDecimals" 10 | Out-null
					$BlankCheck = ArrayBlankCheck($NumDecimals)
					UpdateDocNotes "BlankCheck: $BlankCheck" 10 | Out-null
					

					#Value 4 is the Status FieldID
					[string]$Status_FIELDID = $PARAM.Field[$Parameters_Value4]
					UpdateDocNotes "Status_FIELDID: $Status_FIELDID" 10 | Out-null
					[string]$FLAG = $Context.File.Field[[int]$Status_FIELDID]
					UpdateDocNotes "FLAG: $FLAG" 10 | Out-null
					$Value4IsInt = $NumDecimals -match "^\d+$"
					UpdateDocNotes "Value4IsInt: $Value4IsInt" 10 | Out-null
					$BlankCheck = ArrayBlankCheck($Status_FIELDID)
					
							
					UpdateDocNotes "BlankCheck: $BlankCheck" 10 | Out-null
						
					#Check Param Value2 fields have same number of FieldIDs for Context Project and Foreign Project (e.g. 2,3_4,7)  
					if (($BlankCheck -eq "TRUE") -or ($SourceKeyFields.Count -ne 3) -or ($ForeignKeyFields.Count -ne 3) -or ($Value3IsInt -eq $False) -or ($Value4IsInt -eq $False)) {
						UpdateDocNotes "Please contact the support team. HeaderAmountValidation Parameter values have not been configured correctly." 2 | Out-null
						$FLAG = "EXCEPTION - PARAMETERS"
					} 
					else { 
						[string[]]$HeaderFieldNames = GetHFieldList($SourceKeyFields)
						[string]$ExGST_FieldName = $HeaderFieldNames[0]
						[string]$GST_FieldName = $HeaderFieldNames[1]
						[string]$IncGST_FieldName = $HeaderFieldNames[2]
				
						#If parameter is enabled, continue
						[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
						if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
							UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

							#Set amount variables from fb fields
							[decimal]$HeaderExGST = $Context.File.Field[$Header_TotalExGST_FIELDID]
							[decimal]$HeaderGST = $Context.File.Field[$Header_TotalGST_FIELDID]
							[decimal]$HeaderIncGST = $Context.File.Field[$Header_TotalIncGST_FIELDID]
							
							#Calculate the variance based on the number of decimals specified in the Param Project
							$Variance = 1 / ([math]::Pow(10,[int]$NumDecimals))
							UpdateDocNotes "Variance: $Variance" 10 | Out-null
							
							UpdateDocNotes "HeaderIncGST: $HeaderIncGST" 10 | Out-null
							UpdateDocNotes "HeaderExGST: $HeaderExGST" 10 | Out-null
							UpdateDocNotes "HeaderGST: $HeaderGST" 10 | Out-null
							$Total_Differnce = [math]::abs([decimal]$HeaderIncGST - ([decimal]$HeaderExGST + [decimal]$HeaderGST))
							$Total_Differnce = [math]::abs($Total_Differnce)
							UpdateDocNotes "Total_Differnce: $Total_Differnce" 10 | Out-null
							
							[decimal]$CalcHeaderIncGST = $HeaderExGST + $HeaderGST
							#check difference between gross and net + gst is not greater than variance
							if ($Total_Differnce -gt $Variance)
							{
								UpdateDocNotes "Header Validation failed. Calculated $IncGST_FieldName ($ExGST_FieldName $HeaderExGST + $GST_FieldName $HeaderGST = $CalcHeaderIncGST) does not match $IncGST_FieldName on header ($HeaderIncGST)." 2 | Out-null
								$FLAG = 'EXCEPTION - FAILED HEADER VALIDATION'
								$EXCEPTION = 'YES'
							}
							else
							{
								UpdateDocNotes "$ExGST_FieldName , $GST_FieldName and $IncGST_FieldName calculate correctly on Header." 2 | Out-null
							}      
						}
						else {
							UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
						}
					}
				}
				catch {
					UpdateDocNotes "Please contact the support team. HeaderAmountValidation Parameter values have not been configured correctly." 2 | Out-null
					$FLAG = "EXCEPTION - PARAMETERS"
				}
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | out-null
	UpdateDocNotes "Finished PS HeaderAmountValidation." 10 | Out-null
	return "done"
}


#####################################################################
function ArrayBlankCheck($ParamArray)
{
	#Checking each item of the Paramter Array for blanks
	UpdateDocNotes "ParamArray Value: $ParamArray" 10 | Out-null
	try {
		for ($f = 0; $f -lt $ParamArray.Count; $f++){
			$ParamItemValue = $ParamArray[$f]
			UpdateDocNotes "ParamItemValue: $ParamItemValue" 10 | Out-null
			if ($ParamArray[$f] -eq "") {
				$BlankCheck = "TRUE"
			}
		}
	}
	catch {
		UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
		$FLAG = "EXCEPTION - PARAMETERS"
	}
	return $BlankCheck
}

#####################################################################

function DuplicateCheck
{
	#Checks to see if file is a duplicate based on reference number and supplier
	UpdateDocNotes "Running PS DuplicateCheck." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill() | Out-Null
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'DuplicateCheck' #Filter on function name
		$PARAM.Fill() | Out-Null

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -lt 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {

			
			#Looping through each entry in the Param Project for DuplicteCheck
			for ($p = 0; $p -lt $PARAM.Count; $p++) {
				$ParamLine = $PARAM[$p]
				
				#If parameter is not enabled, silent quit
				if ($ParamLine.Field[$Parameters_Status] -ne "ENABLED") {
					UpdateDocNotes "DuplicateCheck is disabled." 10 | Out-null
				}
				else {
					#If parameter is enabled, continue
					[string]$Val_Param = $ParamLine.Field[$Parameters_Value1]
					if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
						UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

						# Value 2 contains the first set of fields to Check Duplicates on
						[string[]]$KeyFields = [string]$ParamLine.Field[$Parameters_Value2] -split "_"
						[string[]]$SourceKeyFields = $KeyFields[0] -split ","
						[string[]]$ForeignKeyFields = $KeyFields[1] -split ","
						
						#Value 3 contains the Status FieldID and and the Status Value (e.g. REJECTED ....)
						[string[]]$MappedFields = [string]$ParamLine.Field[$Parameters_Value3] -split "_"
						[string]$StatusFieldNumber = $MappedFields[0]
						[string]$StatusFieldValues = $MappedFields[1]
										
						$Count_SourceKeyFields = $SourceKeyFields.Count
						$Count_ForeignKeyFields = $ForeignKeyFields.Count
						$Count_StatusFieldNumber = $StatusFieldNumber.Count
						$Count_StatusFieldValues = $StatusFieldValues.Count
						
						UpdateDocNotes "SourceKeyFields Value: $SourceKeyFields" 10 | Out-null
						UpdateDocNotes "Count_SourceKeyFields: $Count_SourceKeyFields" 10 | Out-null
						UpdateDocNotes "ForeignKeyFields Values: $ForeignKeyFields" 10 | Out-null
						UpdateDocNotes "Count_ForeignKeyFields: $Count_ForeignKeyFields" 10 | Out-null
						UpdateDocNotes "Count_StatusFieldNumber: $Count_StatusFieldNumber" 10 | Out-null
						UpdateDocNotes "Count_StatusFieldValues: $Count_StatusFieldValues" 10 | Out-null
						
						$BlankCheck = "FALSE"
						$BlankCheck = ArrayBlankCheck($SourceKeyFields)
						$BlankCheck = ArrayBlankCheck($ForeignKeyFields)
					
						
						UpdateDocNotes "BlankCheck: $BlankCheck" 10 | Out-null
						#Check Param Value2 fields have same number of FieldIDs for Context Project and Foreign Project (e.g. 2,3_4,7)  
						if (($BlankCheck -eq "TRUE") -or ($SourceKeyFields.Count -ne $ForeignKeyFields.Count) -or ($StatusFieldNumber -eq "") -or ($StatusFieldValues -eq ""))
						{
							UpdateDocNotes "Please contact the support team. DuplicateCheck Parameter values have not been configured correctly." 2 | Out-null
							$FLAG = "EXCEPTION - PARAMETERS"
						}
						else
						{
							UpdateDocNotes "Paramaters have been setup correctly for Duplicate Check ." 10 | Out-null 
							try {
								$current_fc = New-Object FileBound.Filecollection
								$Context.Business.WireCollection($current_fc) #hook the object to the Object Model
								$current_fc.Filter.ProjectID = $Context.File.ProjectID # ProjectID where the Present Invoice is checked for its duplicate.
								
								
								for ($k = 0; $k -lt $SourceKeyFields.Count; $k++) {
									[int]$SourceKeyFieldID = $SourceKeyFields[$k]
									[int]$ForeignFieldID = $ForeignKeyFields[$k]
									
									UpdateDocNotes "SourceKeyFieldID: $SourceKeyFieldID" 10 | Out-null
									UpdateDocNotes "ForeignFieldID: $ForeignFieldID" 10 | Out-null
									$current_fc.Filter.Field[$ForeignFieldID] = $Context.File.Field[$SourceKeyFieldID]
									$SearchValue = $Context.File.Field[$SourceKeyFieldID]
									UpdateDocNotes "SearchValue: $SearchValue" 10 | Out-null
								}
								$current_fc.Filter.Field[$StatusFieldNumber] = "!" + $StatusFieldValues
								
								UpdateDocNotes "StatusFieldValues: $StatusFieldValues" 10 | Out-null
								$current_fc.Fill() | Out-Null
								
								$CountFiles = $current_fc.count
								UpdateDocNotes "CountFiles: $CountFiles" 10 | Out-null
								
								if($ParamLine.Field[$Parameters_ContextProject] -eq $ParamLine.Field[$Parameters_ForeignProject]) {
									[int]$Comparison_Val = 1
								}
								else {
									[int]$Comparison_Val = 0
								}
								if($CountFiles -gt $Comparison_Val) {        
									$FLAG = 'EXCEPTION - DUPLICATE DOCUMENT'
									UpdateDocNotes "A duplicate file has been found. Please check duplicate files." 2 | Out-null
								}
								else {
									#not a duplicate
								}
							}
							catch {
								$FLAG = 'EXCEPTION - PARAM'
								UpdateDocNotes "ERROR in field values. Please contact the support team. DuplicateCheck Parameter values have not been configured correctly  " 2 | Out-null
							}  
						}

					}
					else {
						UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
					}     
						
				}  
						
			}
		}
		
	}


	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | out-null
	UpdateDocNotes "Finished PS DuplicateCheck." 10 | Out-null
	return "done"
}

#####################################################################
function LIBlankCheck 
{
	#Checks to see if the required line item fields are blank
	UpdateDocNotes "Running PS LIBlankCheck." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	$ED_FOUND = "NO"
	[string]$Val_File = " "
	[int]$linecount = 0
	
	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill() | Out-Null
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {

		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'LIBlankCheck' #Filter on function name
		$PARAM.Fill() | Out-Null

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "LIBlankCheck is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null
					
					#get Paramater Value2 Field Ids to check for blanks
					[string]$FieldList = $PARAM.Field[$Parameters_Value2]
					[string[]]$ParamFieldArray = [string]$FieldList -split ","
					[int]$FieldCount = $ParamFieldArray.Length
				
					#Ensure there is at least one field to validate
					if ($FieldCount -eq 0) 
					{
						UpdateDocNotes "No fields listed for validation. Please contact the support team." 2 | Out-null
						$FLAG = "EXCEPTION - PARAMETERS"
					}
					else {
						UpdateDocNotes "Field Count = $FieldCount" 10 | Out-null
						$Context.File.LineItems.Fill() | Out-Null
						if ($Context.File.LineItems.Count -eq 0) {
							UpdateDocNotes "No line items found on the file." 2 | Out-null
							$FLAG = "EXCEPTION - NO LINES"
							$EXCEPTION = "YES"
						}
						else {
							#get list of li field names from another param
							[string[]]$FieldNames = GetLIFieldList($ParamFieldArray)
							#For each ID in the Param Project Value2
							for ($p = 0; $p -lt $FieldCount; $p++) {
								UpdateDocNotes "FieldCount: $FieldCount" 10 | Out-null
								UpdateDocNotes "FieldNames: $FieldNames" 10 | Out-null

								$LineCount = $Context.File.LineItems.Count
								UpdateDocNotes "LineCount = $LineCount" 10 | Out-null
								$lineno = 0
								for ($LiNum = 0; $LiNum -lt $LineCount; $LiNum++) {       
									$lineno++
									$LI = $Context.File.LineItems[$LiNum]
									try {
										#get field number and name for li field
										[int]$FieldNumber = $ParamFieldArray[$p]
										UpdateDocNotes "FieldNumber = $FieldNumber" 10 | Out-null
										$FieldName = $FieldNames[$p]
										UpdateDocNotes "FieldName = $FieldName" 10 | Out-null
									}
									catch {
										#catch error
										UpdateDocNotes "A field listed in LIBlankCheck parameters is incorrect. Please contact support." 2 | Out-null
										$FLAG = "EXCEPTION - PARAMETERS"
									}
								
									#if field is blank exception - check if fieldID exists in configured Param IDs
									if ($LI.Field[$FieldNumber] -eq '') {
										UpdateDocNotes "$FieldName is blank in line $lineno, please populate this field." 2 | Out-null
										$FLAG = "EXCEPTION - BLANK FIELD"
										$EXCEPTION = "YES"
									}
									else {
										UpdateDocNotes "$FieldName is populated." 10 | Out-null
									}
								}
							}
						}
					}
					if ($EXCEPTION -eq "NO") {
						UpdateDocNotes "All fields populated." 10 | Out-null
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS LIBlankCheck." 10 | Out-null
	return "done"

}

#####################################################################


function LIAmountValidation
{
	#This script is used to calculate an amount field (NET, GST & GROSS), provided that two of the three fields are not empty.
	#This script assumes all three above fields have been set up as NUMERIC field types.
	#It will also add a variance of 1 cent to Header Net when needed and recalculate the header fields.
	
	UpdateDocNotes "Running PS LIAmountValidation." 10 | Out-null
	
	#EDIT THE BELOW PARAMETERS
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}
					UpdateDocNotes "line 0.1 Flag: $FLAG" 10 | Out-null
	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'LIAmountValidation' #Filter on function name
		$PARAM.Fill()
									UpdateDocNotes "line 0.2 Flag: $FLAG" 10 | Out-null
		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "LIAmountValidation is disabled." 10 | Out-null
			}
			else {
				try {
					#If parameter is enabled, continue
					
					#Get values from PARAM project 
					UpdateDocNotes "line 0.3 Flag: $FLAG" 10 | Out-null
					# Value 2 contains Field Ids in the following order (ExGST,GST,IncGST_ExGST,GST,IncGST) for Context_Foreign projects. 
					[string[]]$KeyFields = $PARAM.Field[$Parameters_Value2] -split "_"
					[string[]]$SourceKeyFields = $KeyFields[0] -split ","
					[string[]]$ForeignKeyFields = $KeyFields[1] -split ","
					
					#Set ExGST,GST and IncGST FieldIDs from Param project for Header and Line
					[int]$Header_TotalExGST_FIELDID = $SourceKeyFields[0]
					[int]$Header_TotalGST_FIELDID = $SourceKeyFields[1]
					[int]$Header_TotalIncGST_FIELDID = $SourceKeyFields[2]
					
					[int]$Line_LineExGST_FIELDID = $ForeignKeyFields[0]
					[int]$Line_LineGST_FIELDID = $ForeignKeyFields[1]
					[int]$Line_LineIncGST_FIELDID = $ForeignKeyFields[2]
					
												
					$Count_SourceKeyFields = $SourceKeyFields.Count
					$Count_ForeignKeyFields = $ForeignKeyFields.Count

					UpdateDocNotes "SourceKeyFields Value: $SourceKeyFields" 10 | Out-null
					UpdateDocNotes "Count_SourceKeyFields: $Count_SourceKeyFields" 10 | Out-null
					UpdateDocNotes "ForeignKeyFields Values: $ForeignKeyFields" 10 | Out-null
					UpdateDocNotes "Count_ForeignKeyFields: $Count_ForeignKeyFields" 10 | Out-null

					$BlankCheck = "FALSE"
					$BlankCheck = ArrayBlankCheck($SourceKeyFields)
					$BlankCheck = ArrayBlankCheck($ForeignKeyFields)

					# Value 3 contains the variance amount in cents (e.g. 1 cent, 2 cent)
					[string]$NumDecimals = $PARAM.Field[$Parameters_Value3]
					
					#Check if Value 3 is an integer
					$Value3IsInt = $NumDecimals -match "^\d+$"
					UpdateDocNotes "Value3IsInt: $Value3IsInt" 10 | Out-null
					$BlankCheck = ArrayBlankCheck($NumDecimals)
					

					#Value 4 is the Status FieldID
					[string]$Status_FIELDID = $PARAM.Field[$Parameters_Value4]
					[string]$FLAG = $Context.File.Field[$Status_FIELDID]
					$Value4IsInt = $NumDecimals -match "^\d+$"
					UpdateDocNotes "Value4IsInt: $Value4IsInt" 10 | Out-null
					$BlankCheck = ArrayBlankCheck($Status_FIELDID)
					
							
					UpdateDocNotes "BlankCheck: $BlankCheck" 10 | Out-null
								#debug 1
					[int]$skf = $SourceKeyFields.Count
					[int]$fkf = $ForeignKeyFields.Count
					
					UpdateDocNotes "line 1 SourceKeyFields: $skf"  10 | Out-null
					UpdateDocNotes "line 2 ForeignKeyFields: $fkf" 10 | Out-null
					UpdateDocNotes "line 3 Value3IsInt: $Value3IsInt" 10 | Out-null
					UpdateDocNotes "line 4 Value4IsInt: $Value4IsInt" 10 | Out-null
					UpdateDocNotes "line 5 BlankCheck: $BlankCheck" 10 | Out-null
					UpdateDocNotes "line 5 Flag: $FLAG" 10 | Out-null
					
					
					
					$reply = (($BlankCheck -eq "TRUE") -or ($SourceKeyFields.Count -ne 3) -or ($ForeignKeyFields.Count -ne 3) -or ($Value3IsInt -eq $False) -or ($Value4IsInt -eq $False))
					
					UpdateDocNotes "line 6 reply: $reply" 10 | Out-null
					
					#Check Param Value2 fields have same number of FieldIDs for Context Project and Foreign Project (e.g. 2,3_4,7)  
					if (($BlankCheck -eq "TRUE") -or ($SourceKeyFields.Count -ne 3) -or ($ForeignKeyFields.Count -ne 3) -or ($Value3IsInt -eq $False) -or ($Value4IsInt -eq $False)) {
						UpdateDocNotes "Please contact the support team. LIAmountValidation Parameter values have not been configured correctly." 2 | Out-null
						$FLAG = "EXCEPTION - PARAMETERS"

					} 
					else { 
			
						[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
						if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
							UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null
						
							#EDIT THE BELOW PARAMETERS
							[decimal]$HeaderTotalExGST = [decimal]$Context.File.Field[$Header_TotalExGST_FIELDID]
							[decimal]$HeaderTotalGST = [decimal]$Context.File.Field[$Header_TotalGST_FIELDID]
							[decimal]$HeaderTotalIncGST = [decimal]$Context.File.Field[$Header_TotalIncGST_FIELDID]
							
							$Context.File.LineItems.Fill()
							#check theres lines
							if ($Context.File.LineItems.Count -eq 0) #If there are no line items
							{
								UpdateDocNotes "No Line Items found in the file." 10 | Out-null
								$EXCEPTION = 'YES'
							}
							else
							{
							
								[string[]]$LiFieldNames = GetLiFieldList($ForeignKeyFields)
								[string]$ExGST_FieldName = $LiFieldNames[0]
								[string]$GST_FieldName = $LiFieldNames[1]
								[string]$IncGST_FieldName = $LiFieldNames[2]
								
								[decimal]$LI_Net_Total = 0 
								[decimal]$LI_GST_Total = 0 
								[decimal]$LI_Gross_Total = 0   
								[int]$i = 0
								
								UpdateDocNotes "line 11 flag: $FLAG" 10 | Out-null
								foreach ($LI in $Context.File.LineItems)
								{
								
									$LI.Field[$Line_LineExGST_FIELDID] = [math]::Round(([decimal]$LI.Field[$Line_LineExGST_FIELDID]),[int]$NumDecimals,1)
									$LI.Field[$Line_LineGST_FIELDID] = [math]::Round(([decimal]$LI.Field[$Line_LineGST_FIELDID]),[int]$NumDecimals,1)
									$LI.Field[$Line_LineIncGST_FIELDID] = [math]::Round(([decimal]$LI.Field[$Line_LineIncGST_FIELDID]),[int]$NumDecimals,1)
									$LI.Save() | Out-Null
									
									#EDIT THE BELOW PARAMETERS
									[string]$LINet = [string]$LI.Field[$Line_LineExGST_FIELDID]
									[string]$LIGST = [string]$LI.Field[$Line_LineGST_FIELDID]
									[string]$LIGross = [string]$LI.Field[$Line_LineIncGST_FIELDID]
							
									[string]$LI.Field[$Status_FIELDID] = ''
									$LI.Save() | Out-null
									$i++
									if (([string]$LINet -eq '') -or ([string]$LIGST -eq '') -or ([string]$LIGross -eq '')) 
									{
										UpdateDocNotes "Unable to perform line item amount validation - Line $i is missing one or more of $LiFieldNames." 2 | out-null
										$FLAG = 'EXCEPTION - ASSIGNED TO AP TEAM'
										$EXCEPTION = 'YES'
										#EDIT THE BELOW PARAMETER
										[string]$LI.Field[$Status_FIELDID] = 'EXCEPTION'
										$LI.Save() | Out-null
									}
									else
									{
										#Calculate the variance based on the number of decimals specified in the Param Project
										$Variance = 1 / ([math]::Pow(10,[int]$NumDecimals))
										UpdateDocNotes "Variance: $Variance" 10 | Out-null
																										
										$Total_Differnce = [math]::abs($LIGross) - [math]::abs([decimal]$LINet + [decimal]$LIGST)
										$Total_Differnce = [math]::abs($Total_Differnce)
										#check difference between gross and net + gst is not greater than variance
										if ($Total_Differnce -gt $Variance)
										{
											UpdateDocNotes "$ExGST_FieldName , $GST_FieldName and $IncGST_FieldName don't add together on line $i." 2 | Out-null         
											$FLAG = 'EXCEPTION - ASSIGNED TO AP TEAM'
											$EXCEPTION = 'YES'
										}
										else
										{
											UpdateDocNotes "$ExGST_FieldName , $GST_FieldName and $IncGST_FieldName calculate correctly on line $i." 2 | Out-null
										}
									}
								}
							}
						}
						else {
							UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
						}
					}
				}
				catch {
					UpdateDocNotes "Please contact the support team. LIAmountValidation Parameter values have not been configured correctly." 2 | Out-null 
					$FLAG = "EXCEPTION - PARAMETERS"
				}
				UpdateDocNotes "line 11 flag: $FLAG" 10 | Out-null
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | out-null
	UpdateDocNotes "Finished PS LIAmountValidation." 10 | Out-null
	return "done"
}
#####################################################################

function LineItemUIDUpdate
{
	#Updates UID of all lines to match header
	UpdateDocNotes "Running PS LineItemUIDUpdate." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'LineItemUIDUpdate' #Filter on function name
		$PARAM.Fill()

		#If param not found in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "LineItemUIDUpdate is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					$Context.File.LineItems.Fill()
					#flag if UID missing on header
					if ($Context.File.Field[$UID_FIELDID] -eq '') {
						$FLAG = 'EXCEPTION'
						UpdateDocNotes "No UID found on file." 2 | Out-null
					}
					else {
						#flag if there are no line items
						if ($Context.File.LineItems.Count -eq 0) {
							UpdateDocNotes "No line items found on file." 10 | Out-null
						}
						else {
						#Copy header UID to each line item
							foreach ($LI in $Context.File.LineItems) {
								[string]$UID = $Context.File.Field[$UID_FIELDID]
								$LI.Field[$UID_FIELDID] = $UID
								$LI.Save() | Out-null
							}
						}
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | out-null
	UpdateDocNotes "Finished PS LineItemUIDUpdate." 10 | Out-null
	return "done"
}

#####################################################################

function CalculateLINet
{
	# Calculate LI Net if unit price and qty are present

	UpdateDocNotes "Running PS CalculateLINet." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'CalculateLINet' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "CalculateLINet is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					#cycle through lines checking if li net is blank
					$Context.File.LineItems.Fill()
					if ($Context.File.LineItems.Count -gt 0) {
						foreach ($LI in $Context.File.LineItems) {
							if ([string]$LI.Field[$Line_LineExGST_FIELDID] -ne '') {
								UpdateDocNotes "Line Ex GST already populated for this line." 10 | Out-null
							}
							#if li net is blank check to see if either qty or price is blank
							elseif (([string]$LI.Field[$Line_Quantity_FIELDID] -eq '') -or ([string]$LI.Field[$Line_Price_FIELDID] -eq '')) {
								UpdateDocNotes "Cannot calculate Line Ex GST as Quantity and/or Unit Price is missing." 2 | Out-Null
							}
							else {
								#is neither are blank calculate li net
								[decimal]$LINet = [decimal]$LI.Field[$Line_Quantity_FIELDID] * [decimal]$LI.Field[$Line_Price_FIELDID]
								$LI.Field[$Line_LineExGST_FIELDID] = $LINet
								$LI.Save() | Out-null
								UpdateDocNotes "Line Ex GST was automatically calculated from Quantity and Unit Price." 2 | Out-null
							}
						}
					}
				}
				else {
					#debug
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS CalculateLINet." 10 | Out-null
	return "done"
}

#####################################################################

function CalculateLIGST
{
	# Calculate LI GST if net and tax are present

	UpdateDocNotes "Running PS CalculateLIGST." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'CalculateLIGST' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "CalculateLIGST is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					#cycle through li till there is a blank gst
					$Context.File.LineItems.Fill()
					if ($Context.File.LineItems.Count -gt 0) {
						foreach ($LI in $Context.File.LineItems) {
							if ([string]$LI.Field[$Line_LineGST_FIELDID] -ne '') {
								UpdateDocNotes "Line GST already populated for this line." 10 | Out-null
							}
							#check that line net and tax code are populated
							elseif (([string]$LI.Field[$Line_LineExGST_FIELDID] -eq '') -or ([string]$LI.Field[$Line_TaxCode_FIELDID] -eq '')) {
								UpdateDocNotes "Cannot calculate Line GST as Line Ex GST and/or Tax Code is missing." 2 | Out-Null
							}
							else {
								#find tax rate from code
								UpdateDocNotes "Lookup tax code" 10 | Out-Null
								$code = $LI.Field[$Line_TaxCode_FIELDID]

								#Find Tax Code
								$TaxCode = New-Object FileBound.FileCollection
								$Context.Business.WireCollection($TaxCode)   #hook the object to the Object Model
								$TaxCode.Filter.ProjectID = $TaxCode_ProjectID
								$TaxCode.Filter.Field[$TaxCode_TaxCode] = [string]$LI.Field[$Line_TaxCode_FIELDID]
								$TaxCode.Fill()
								
								#invalid tax code exception handling
								if ($TaxCode.Count -ne 1) {
									UpdateDocNotes "Invalid Tax Code ($code). Please consult REF - Tax Code." 2 | Out-Null
									$FLAG = "EXCEPTION - INVALID TAX CODE"
								}
								else {
									#blank rate exception handling
									if ($TaxCode[0].Field[$TaxCode_TaxPerc] -eq '') {
										UpdateDocNotes "No Tax Percentage for Tax Code $code." 2 | Out-Null
										$FLAG = "EXCEPTION - INVALID TAX CODE"
									}
									else {
										#calculate gst from net * (tax rate/100)
										[decimal]$perc = [decimal]$TaxCode[0].Field[$TaxCode_TaxPerc] * 0.01
										[decimal]$LIGST = [decimal]$LI.Field[$Line_LineExGST_FIELDID] * [decimal]$perc
										$LI.Field[$Line_LineGST_FIELDID] = $LIGST
										$LI.Save() | Out-null
										UpdateDocNotes "Line GST was automatically calculated from Line Ex GST and Tax Code." 2 | Out-null
									}
								}
							}
						}
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS CalculateLIGST." 10 | Out-null
	return "done"
}

#####################################################################

function CalculateLIGross
{
	#Calculate LI Gross if gst and net are present

	UpdateDocNotes "Running PS CalculateLIGross." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'CalculateLIGross' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "CalculateLIGross is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					#cycle through li till blank gross
					$Context.File.LineItems.Fill()
					if ($Context.File.LineItems.Count -gt 0) {
						foreach ($LI in $Context.File.LineItems) {
							if ([string]$LI.Field[$Line_LineIncGST_FIELDID] -ne '') {
								UpdateDocNotes "Line Inc GST already populated for this line." 10 | Out-null
							}
							#check gst and net arent blank
							elseif (([string]$LI.Field[$Line_LineExGST_FIELDID] -eq '') -or ([string]$LI.Field[$Line_LineGST_FIELDID] -eq '')) {
								UpdateDocNotes "Cannot calculate Line Inc GST as Line Ex GST and/or Line GST is missing." 2 | Out-Null
							}
							else {
								#calc gross form net + gst
								[decimal]$LIGross = [decimal]$LI.Field[$Line_LineExGST_FIELDID] + [decimal]$LI.Field[$Line_LineGST_FIELDID]
								$LI.Field[$Line_LineIncGST_FIELDID] = $LIGross
								$LI.Save() | Out-null
								UpdateDocNotes "Line Inc GST was automatically calculated from Line Ex GST and Line GST." 2 | Out-null
							}
						}
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	#Assign status flag
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS CalculateLIGross." 10 | Out-null
	return "done"
}

#####################################################################

function LiAndHedaerAmountValidation
{
	#This script is used to Validate Header Amounts vs Total Line Amounts
	#This script assumes all fields in the Param Project have been set up as NUMERIC field types.
	
	UpdateDocNotes "Running PS LiAndHedaerAmountValidation." 10 | Out-null
	
	#Set status flag and exception flag
	[string]$FLAG = $Context.File.Field[$Status_FIELDID]
	[string]$EXCEPTION = "NO"
	[string]$ED_FOUND = "NO"

	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill() | Out-Null
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team." 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {
	
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = 'LiAndHedaerAmountValidation' #Filter on function name
		$PARAM.Fill() | Out-Null

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly." 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "LiAndHedaerAmountValidation is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) 
				{
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null
				
					try {
						#EDIT THE BELOW PARAMETERS

						# Value 2 contains the first set of fields to Check Line Amounts vs Header Amounts on
						[string[]]$KeyFields = $PARAM.Field[$Parameters_Value2] -split "_"
						[string[]]$SourceKeyFields = $KeyFields[0] -split ","
						[string[]]$ForeignKeyFields = $KeyFields[1] -split ","
									
						$Count_SourceKeyFields = $SourceKeyFields.Count
						$Count_ForeignKeyFields = $ForeignKeyFields.Count
						
						UpdateDocNotes "SourceKeyFields Value: $SourceKeyFields" 10 | Out-null
						UpdateDocNotes "Count_SourceKeyFields: $Count_SourceKeyFields" 10 | Out-null
						UpdateDocNotes "ForeignKeyFields Values: $ForeignKeyFields" 10 | Out-null
						UpdateDocNotes "Count_ForeignKeyFields: $Count_ForeignKeyFields" 10 | Out-null
						
						$BlankCheck = "FALSE"
						$BlankCheck = ArrayBlankCheck($SourceKeyFields)
						$BlankCheck = ArrayBlankCheck($ForeignKeyFields)

						# Value 3 contains the number of decimal places to round to
						[string]$NumDecimals = $PARAM.Field[$Parameters_Value3]
						
						#Check if Value 3 is an integer
						$Value3IsInt = $NumDecimals -match "^\d+$"
						UpdateDocNotes "Value3IsInt: $Value3IsInt" 10 | Out-null
						$BlankCheck = ArrayBlankCheck($NumDecimals) 

					
						#Value 4 is the Status FieldID
						[string]$Status_FIELDID = $PARAM.Field[$Parameters_Value4]
						[string]$FLAG = $Context.File.Field[$Status_FIELDID]
						$Value4IsInt = $NumDecimals -match "^\d+$"
						UpdateDocNotes "Value4IsInt: $Value4IsInt" 10 | Out-null
						$BlankCheck = ArrayBlankCheck($Status_FIELDID)
					
										
						UpdateDocNotes "BlankCheck: $BlankCheck" 10 | Out-null
						
						#Check Param Value2 fields have same number of FieldIDs for Context Project and Foreign Project (e.g. 2,3_4,7)  
						if (($BlankCheck -eq "TRUE") -or ($SourceKeyFields.Count -ne $ForeignKeyFields.Count) -or ($Value3IsInt -eq $False) -or ($Value4IsInt -eq $False)) {
							UpdateDocNotes "Please contact the support team. LiAndHedaerAmountValidation Parameter values have not been configured correctly." 2 | Out-null
							$FLAG = "EXCEPTION - PARAMETERS"
						} 
						else {
							
							$Context.File.LineItems.Fill() | Out-Null
							#check there are lines
							if ($Context.File.LineItems.Count -eq 0) #If there are no line items
							{
								UpdateDocNotes "No Line Items found in the file." 10 | Out-null
								$EXCEPTION = 'YES'
							}
							else {
								[string[]]$LiFieldNames = GetLiFieldList($ForeignKeyFields)
								[string[]]$HeaderFieldNames = GetHFieldList($SourceKeyFields)
								#Get the value for each field ID listed in the Param project
								for ($val = 0; $val -lt $Count_SourceKeyFields; $val++) {
									$HeaderFieldID = $SourceKeyFields[$val]
									$Context.Project.Fields.Fill() | Out-Null
									$HeaderAmount_Val = [math]::abs($Context.File.Field[[int]$HeaderFieldID])
									$LiFieldName = $LiFieldNames[$val]
									$HeaderFieldName = $HeaderFieldNames[$val]
									UpdateDocNotes "HeaderAmount_Val: $HeaderAmount_Val" 10 | Out-null
									UpdateDocNotes "HeaderFieldID: $HeaderFieldID" 10 | Out-null

									$Context.File.LineItems.Fill() | Out-Null
									$LiCount = $Context.File.LineItems.Count
									UpdateDocNotes "LineCount = $LineCount" 10 | Out-null
									
									
									$LiTotal_Amount = 0
									$lineno = 0
									#Get the Amount for each Line in the document and add them together
									for ($LiNumber = 0; $LiNumber -lt $LiCount; $LiNumber++) {       
										
										$LINE = $Context.File.LineItems[$LiNumber]
										$lineno++
										$LineFieldID = $ForeignKeyFields[$val]
										$Context.File.LineItems.Fill() | Out-Null
										$LiAmount_Val = [math]::abs($LINE.Field[[int]$LineFieldID])
										UpdateDocNotes "LiAmount_Val: $LiAmount_Val" 10 | Out-null
										UpdateDocNotes "LineFieldID: $LineFieldID" 10 | Out-null
										$LiTotal_Amount = $LiTotal_Amount + $LiAmount_Val
										$LiTotal_Amount = [math]::abs($LiTotal_Amount)

									}
									UpdateDocNotes "LiTotal_Amount: $LiTotal_Amount" 10 | Out-null
									$Total_Differnce = [math]::abs($HeaderAmount_Val) - [math]::abs($LiTotal_Amount)
									
									#Calculate the variance based on the number of decimals specified in the Param Project
									$Variance = 1 / ([math]::Pow(10,[int]$NumDecimals))
									UpdateDocNotes "Variance: $Variance" 10 | Out-null
									#Check the difference between the Header amount and the Line Total amount is not greater than the variace
									if ([math]::abs($Total_Differnce) -gt $Variance) {
										UpdateDocNotes "Header $HeaderFieldName does not match the line total for field $LiFieldName ." 2 | Out-null
										$FLAG = 'EXCEPTION - ASSIGNED TO AP TEAM'
									}
									else {
										UpdateDocNotes "Header $HeaderFieldName matches the total line amount for field $LiFieldName." 2 | Out-null
									}
								}
								
							}
						}
					}
					catch {
						UpdateDocNotes "Please contact the support team. LiAndHedaerAmountValidation Parameter values have not been configured correctly." 2 | Out-null 
						$FLAG = "EXCEPTION - PARAMETERS"
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	
	#EDIT THE BELOW PARAMETER
	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null

	UpdateDocNotes "Finished PS LiAndHedaerAmountValidation." 10 | Out-null
	return "done"
}



function ParameterStatus ([string]$ParameterName)
{
	# This function returns the status of a parameter given the parameters name
	
	UpdateDocNotes "Start ParameterStatus Function at $ParameterName step" 10 | Out-null
	

	try
	{ 
		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameter_ProjectID
		$PARAM.Filter.Field[$Parameter_ContextProject_FieldID] = $Context.Project.ProjectID
		$PARAM.Filter.Field[$Parameter_ParameterName_FieldID] = $ParameterName
		$PARAM.Fill() | Out-null
	
		
		[int]$count = $PARAM.Count 
		UpdateDocNotes "Count: $count" 10 | Out-null
		
		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) 
		{
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. $ParameterName " 2 | Out-null
			[string]$RET_VAL = "EXCEPTION"
		}
		else 
		{
			[string]$RET_VAL = $PARAM[0].Field[19]
			UpdateDocNotes "RET_VAL: $RET_VAL" 10 | Out-null
		}
	}
	catch
	{
		$Error_Message = $_.Exception.Message
		$Message = "ERROR: ParameterStatus ($ParameterName) exception - Message: " + $Error_Message        
		UpdateDocNotes "$Message" 10 | Out-null
		$RET_VAL = "ERROR"
	}
	UpdateDocNotes "ParameterStatus Return Value $RET_VAL" 10 | Out-null

	return $RET_VAL
}



############## SCRIPT  - END ##################


#BELOW TWO SCRIPTS ARE NOT FULLY IMPLEMENTED AND HAVE BEEN COMMENTED OUT - LIAM

#####################################################################
<#
function 2WayHValidation1
{
	UpdateDocNotes "Running PS 2WayHValidation1." 10 | Out-null
	
	#Set status flag and exception flag
	$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	$ED_FOUND = "NO"
	[string]$Val_File = " "
	
	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team.Error: 2WHV1-NO_ED" 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {

		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = '2WayHValidation1' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WHV1-NO_PRM" 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		#If param found, continue
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "2WayHValidation1 is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
				if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
					UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

					if (($PARAM.Field[$Parameters_ForeignProject] -eq '') -or ($PARAM.Field[$Parameters_Value2] -eq '') -or ($PARAM.Field[$Parameters_Value3] -eq '')) {
						UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WHV1-NO_VAL " 2 | Out-null
						$FLAG = "EXCEPTION - PARAMETERS"
					}
					else {
						UpdateDocNotes "Splitting Value2 & Value3" 10 | Out-null
						[int]$ForeignProjID = [int]$PARAM.Field[$Parameters_ForeignProject]
						[string[]]$ContextParams = [string]$PARAM.Field[$Parameters_Value2] -split "_"
						[string[]]$ForeignParams = [string]$PARAM.Field[$Parameters_Value3] -split "_"
						
						UpdateDocNotes "ContextParams 0 $ContextParams[0]" 10 | Out-null
						UpdateDocNotes "ContextParams 1 $ContextParams[1]" 10 | Out-null

						UpdateDocNotes "ForeignProj $ForeignProjID" 10 | Out-null
						UpdateDocNotes "ForeignParams 0 $ForeignParams[0]" 10 | Out-null
						UpdateDocNotes "ForeignParams 1 $ForeignParams[1]" 10 | Out-null

						if (($ContextParams.Length -ne 2) -or ($ForeignParams.Length -ne 2)) {
							UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WHV1-WRNG_CNT" 2 | Out-null
							$FLAG = "EXCEPTION - PARAMETERS"
						}
						else {
							[string[]]$ContextFilter = [string]$ContextParams[0] -split ","
							[string[]]$ContextMatch = [string]$ContextParams[1] -split ","
							[string[]]$ForeignFilter = [string]$ForeignParams[0] -split ","
							[string[]]$ForeignMatch = [string]$ForeignParams[1] -split ","
							
							if (($ContextFilter.Count -ne $ForeignFilter.Count) -or ($ContextMatch.Count -ne $ForeignMatch.Count)) {
								UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: Error: 2WHV1-WRNG_CNT" 2 | Out-null
								$FLAG = "EXCEPTION - PARAMETERS"
							}
							else {
								$ForeignLookup = New-Object FileBound.FileCollection
								$Context.Business.WireCollection($ForeignLookup)   #hook the object to the Object Model
								$ForeignLookup.Filter.ProjectID = $ForeignProjID
								
								for ([int]$i = 0; $i -lt $ContextFilter.Count; $i++) {
									$ForeignLookup.Filter.Field[$ForeignFilter[$i]] = $ContextFilter[$i]
								}
								$ForeignLookup.Fill()

								if ($ForeignLookup.Count -lt 1) {
									UpdateDocNotes "No matches found in other project." 2 | Out-null
									$FLAG = "EXCEPTION - NO RESULTS"
								}
								elseif ($ForeignLookup.Count -gt 1) {
									UpdateDocNotes "More than one match found in other project." 2 | Out-null
									$FLAG = "EXCEPTION - MULTIPLE RESULTS"
								}
								else {
									UpdateDocNotes "One match found." 10 | Out-Null
									
									$Context.Project.Fields.Fill()

									for ([int]$k = 0; $k -lt $ContextMatch.Count; $k++){
										[int]$tempConField = $ContextMatch[$k]
										[int]$tempForField = $ForeignMatch[$k]
										$FieldName = $Context.Project.Fields[$tempConField]

										UpdateDocNotes "Matching Context $FieldName (Field $tempConField) with Foreign Field $tempForField." 10 | Out-null

										if ($Context.File.Field[$tempConField] -eq $ForeignLookup.Field[$tempForField]) {
											UpdateDocNotes "Match" 10 | Out-null
										}
										else {
											UpdateDocNotes "Could not match $FieldName "
											$FLAG = "EXCEPTION - FIELD MISMATCH"
											$EXCEPTION = "YES"
										}

									}
								}
							}
						}
					}
				}
				else {
					UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
				}
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS 2WayHValidation1." 10 | Out-null
	return "done"

}
#>
#####################################################################
<#
function 2WayLineValidation1
{
	#ASSUMPTIONS
	#Contxt LI Lookup Fields must be unique on foreign file's line items (ie, there wont ever be two line with the same stock code)

	UpdateDocNotes "Running PS 2WayLineValidation1." 10 | Out-null
	
	#Set status flag and exception flag
	$FLAG = $Context.File.Field[$Status_FIELDID]
	$EXCEPTION = "NO"
	$ED_FOUND = "NO"
	[string]$Val_File = " "
	[int]$linecount = 0
	
	#Check validation ED exists and save to variable
	$Context.File.ExtraData.Fill()
	foreach ($ED in $Context.File.ExtraData) {
		if ($ED.Variable -eq "VALIDATION") {
			$ED_FOUND = "YES"
			[string]$Val_File = $ED.Value
		}
	}

	#If no ED, exception
	if ($ED_FOUND -eq "NO") {
		UpdateDocNotes "Validation ExtraData was not found on routing document. Please contact the support team.Error: 2WLV1-NO_ED" 2 | Out-null
		$FLAG = "EXCEPTION - EXTRADATA"
	}
	if ($ED_FOUND -eq "YES") {

		#Find Parameter
		$PARAM = New-Object FileBound.FileCollection
		$Context.Business.WireCollection($PARAM)   #hook the object to the Object Model
		$PARAM.Filter.ProjectID = $Parameters_ProjectID
		$PARAM.Filter.Field[$Parameters_ContextProject] = $Context.File.ProjectID #ProjectID is key field in REF - Projects
		$PARAM.Filter.Field[$Parameters_ParamName] = '2WayLineValidation1' #Filter on function name
		$PARAM.Fill()

		#If parameter is not in REF - Parameters, exception
		if ($PARAM.Count -ne 1) {
			UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WLV1-NO_PRM" 2 | Out-null
			$FLAG = "EXCEPTION - PARAMETERS"
		}
		else {
			#If parameter is not enabled, silent quit
			if ($PARAM.Field[$Parameters_Status] -ne "ENABLED") {
				UpdateDocNotes "2WayLineValidation1 is disabled." 10 | Out-null
			}
			else {
				#If parameter is enabled, continue
				$Context.File.LineItems.Fill()
				if ($Context.File.LineItems.Count -eq 0) {
					UpdateDocNotes "Cannot perform two way line item valdiation, there is no line items on the file." 2 | Out-Null
					$FLAG = "EXCEPTION - NO LINES"
				}
				else {
					[string]$Val_Param = $PARAM.Field[$Parameters_Value1]
					if (($Val_Param -eq "ALL") -or ($Val_Param -eq $Val_File)) {
						UpdateDocNotes "Script is set to run for the current VALIDATION value." 10 | Out-null

						if (($PARAM.Field[$Parameters_ForeignProject] -eq '') -or ($PARAM.Field[$Parameters_Value2] -eq '') -or ($PARAM.Field[$Parameters_Value3] -eq '')) {
							UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WLV1-NO_VAL " 2 | Out-null
							$FLAG = "EXCEPTION - PARAMETERS"
						}
						else {
							UpdateDocNotes "Splitting Value2 & Value3" 10 | Out-null
							[int]$ForeignProjID = [int]$PARAM.Field[$Parameters_ForeignProject]
							[string[]]$ContextParams = [string]$PARAM.Field[$Parameters_Value2] -split "_"
							[string[]]$ForeignParams = [string]$PARAM.Field[$Parameters_Value3] -split "_"
							
							UpdateDocNotes "ContextParams 0 $ContextParams[0]" 10 | Out-null
							UpdateDocNotes "ContextParams 1 $ContextParams[1]" 10 | Out-null

							UpdateDocNotes "ForeignProj $ForeignProjID" 10 | Out-null
							UpdateDocNotes "ForeignParams 0 $ForeignParams[0]" 10 | Out-null
							UpdateDocNotes "ForeignParams 1 $ForeignParams[1]" 10 | Out-null

							if (($ContextParams.Length -ne 2) -or ($ForeignParams.Length -ne 2)) {
								UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: 2WLV1-WRNG_CNT" 2 | Out-null
								$FLAG = "EXCEPTION - PARAMETERS"
							}
							else {
								[string[]]$ContextFilter = [string]$ContextParams[0] -split ","
								[string[]]$ContextMatch = [string]$ContextParams[1] -split ","
								[string[]]$ForeignFilter = [string]$ForeignParams[0] -split ","
								[string[]]$ForeignMatch = [string]$ForeignParams[1] -split ","
								
								if (($ContextFilter.Count -ne $ForeignFilter.Count) -or ($ContextMatch.Count -ne $ForeignMatch.Count)) {
									UpdateDocNotes "Please contact the support team. Parameters have not been configured correctly. Error: Error: 2WLV1-WRNG_CNT" 2 | Out-null
									$FLAG = "EXCEPTION - PARAMETERS"
								}
								else {
									#Find file in foreign project
									$ForeignLookup = New-Object FileBound.FileCollection
									$Context.Business.WireCollection($ForeignLookup)
									$ForeignLookup.Filter.ProjectID = $ForeignProjID
									#loop through filter fields
									for ([int]$i = 0; $i -lt $ContextFilter.Count; $i++) {
										$ForeignLookup.Filter.Field[$ForeignFilter[$i]] = $ContextFilter[$i]
									}
									#fill
									$ForeignLookup.Fill()

									#if more/less than 1 match, exception
									if ($ForeignLookup.Count -lt 1) {
										UpdateDocNotes "No matches found in other project." 2 | Out-null
										$FLAG = "EXCEPTION - NO RESULTS"
									}
									elseif ($ForeignLookup.Count -gt 1) {
										UpdateDocNotes "More than one match found in other project." 2 | Out-null
										$FLAG = "EXCEPTION - MULTIPLE RESULTS"
									}
									#if only 1 match, continue
									else {
										UpdateDocNotes "One match found." 10 | Out-Null
										
										[string[]]$FieldNames = GetLIFieldList

										$ForeignLookup.LineItems.Fill()
										if ($ForeignLookup.LineItems.Count -eq 0) {
											UpdateDocNotes "Cannot perform two way line item valdiation, there is no line items on the matched file." 2 | Out-Null
											$FLAG = "EXCEPTION - NO LINES"
										}
										else {
											UpdateDocNotes "Need to add CODE in 2WayLineValidation1 Function in the Validation Workflow !!!!!!!!!" 10 | Out-Null




										}
									}
								}
							}
						}
					}
					else {
						UpdateDocNotes "Val Param = $Val_Param, Val File = $Val_File. Script will not run." 10 | Out-null
					}
				}
			}
		}
	}

	$Context.File.Field[$Status_FIELDID] = $FLAG
	$Context.File.Save() | Out-null
	UpdateDocNotes "Finished PS 2WayLineValidation1." 10 | Out-null
	return "done"

}

#####################################################################

#>
