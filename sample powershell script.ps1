
Function setLogo($sitePath) {
	Write-Host -nonewline "Setting default site logo..."
	$siteCollectionURL = $focalpointURL + "/extranets/" + $sitePath
	$web = Get-SPWeb $siteCollectionURL
	$rootWeb = Get-SPWeb $focalpointURL
	$rootConfigurationList = $rootWeb.Lists["Site Configuration"]
	ForEach ($item in $rootConfigurationList.Items) {		
		if ($item.Name -eq "right logo"){
			$rootLogo = $item
		}
	}
	
	$siteLogo = $rootLogo.Attachments.UrlPrefix + $rootLogo.Attachments.Item(0)
	$web.SiteLogoUrl=$sitelogo
	$web.Update()
	Write-Host -ForegroundColor Green "Done!"
}

Function setAuditLogging ($sitePath){
Write-Host -nonewline "Setting audit log settings..."
	$siteCollectionURL = $focalpointURL + "/extranets/" + $sitePath
	$site = Get-SpSite $siteCollectionURL
	$auditMask = [Microsoft.Sharepoint.SPAuditMaskType]::All
	$site.TrimAuditLog = $true
	$site.Audit.AuditFlags = $auditMask
	$site.Audit.Update()
	$site.AuditLogTrimmingRetention = 30
	Write-Host -ForegroundColor Green "Done!"
}

function addCalendar($sitePath)
{
	Write-Host -nonewline "Adding Calendar to page..."
	$siteCollectionURL = $focalpointURL + "/extranets/" + $sitePath
	$web = Get-SPWeb $siteCollectionURL
	$page = $web.GetFile("Pages/calendar.aspx")
	if($page -ne $null)
	{
		if($page.CheckedOutByUser -ne $null){
			$page.UndoCheckOut()
		}
		$page.CheckOut()
		$calendar = $web.Lists["Calendar"]
		$pageManager = $page.GetLimitedWebPartManager([System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
		$view = New-Object "Microsoft.SharePoint.WebPartPages.ListViewWebPart"
		$view.ListId = $calendar.ID
		$pageManager.AddWebPart($view,"Zone 1",1)
		$pageManager.SaveChanges($view)
		$pageManager.Dispose()
		$page.Properties["vti_title"] = "Calendar"
		$page.Update()
		$page.CheckIn("")
		$page.Publish("")
		Write-Host -ForegroundColor Green "Done!"
	}
	else
	{
		Write-Host -ForegroundColor Red "Page not found"
	}
}