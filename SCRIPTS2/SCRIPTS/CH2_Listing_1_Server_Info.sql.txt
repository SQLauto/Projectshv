SELECT  CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
        CONVERT(CHAR(100), SERVERPROPERTY('ProductVersion')) AS ProductVersion,
        CONVERT(CHAR(100), SERVERPROPERTY('ProductLevel')) AS ProductLevel,
        CONVERT(CHAR(100), SERVERPROPERTY('ResourceLastUpdateDateTime')) AS ResourceLastUpdateDateTime,
        CONVERT(CHAR(100), SERVERPROPERTY('ResourceVersion')) AS ResourceVersion,
        CASE WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 1
             THEN 'Integrated security'
             WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 0
             THEN 'Not Integrated security'
        END AS IsIntegratedSecurityOnly,
        CASE WHEN SERVERPROPERTY('EngineEdition') = 1 THEN 'Personal Edition'
             WHEN SERVERPROPERTY('EngineEdition') = 2 THEN 'Standard Edition'
             WHEN SERVERPROPERTY('EngineEdition') = 3
             THEN 'Enterprise Edition'
             WHEN SERVERPROPERTY('EngineEdition') = 4 THEN 'Express Edition'
        END AS EngineEdition,
        CONVERT(CHAR(100), SERVERPROPERTY('InstanceName')) AS InstanceName,
        CONVERT(CHAR(100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS,
        CONVERT(CHAR(100), SERVERPROPERTY('LicenseType')) AS LicenseType,
        CONVERT(CHAR(100), SERVERPROPERTY('NumLicenses')) AS NumLicenses,
        CONVERT(CHAR(100), SERVERPROPERTY('BuildClrVersion')) AS BuildClrVersion,
        CONVERT(CHAR(100), SERVERPROPERTY('Collation')) AS Collation,
        CONVERT(CHAR(100), SERVERPROPERTY('CollationID')) AS CollationID,
        CONVERT(CHAR(100), SERVERPROPERTY('ComparisonStyle')) AS ComparisonStyle,
        CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('EditionID')) = -1253826760
             THEN 'Desktop Edition'
             WHEN SERVERPROPERTY('EditionID') = -1592396055
             THEN 'Express Edition'
             WHEN SERVERPROPERTY('EditionID') = -1534726760
             THEN 'Standard Edition'
             WHEN SERVERPROPERTY('EditionID') = 1333529388
             THEN 'Workgroup Edition'
             WHEN SERVERPROPERTY('EditionID') = 1804890536
             THEN 'Enterprise Edition'
             WHEN SERVERPROPERTY('EditionID') = -323382091
             THEN 'Personal Edition'
             WHEN SERVERPROPERTY('EditionID') = -2117995310
             THEN 'Developer Edition'
             WHEN SERVERPROPERTY('EditionID') = 610778273
             THEN 'Enterprise Evaluation Edition'
             WHEN SERVERPROPERTY('EditionID') = 1044790755
             THEN 'Windows Embedded SQL'
             WHEN SERVERPROPERTY('EditionID') = 4161255391
             THEN 'Express Edition with Advanced Services'
        END AS ProductEdition,
        CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('IsClustered')) = 1
             THEN 'Clustered'
             WHEN SERVERPROPERTY('IsClustered') = 0 THEN 'Not Clustered'
             WHEN SERVERPROPERTY('IsClustered') = NULL THEN 'Error'
        END AS IsClustered,
        CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('IsFullTextInstalled')) = 1
             THEN 'Full-text is installed'
             WHEN SERVERPROPERTY('IsFullTextInstalled') = 0
             THEN 'Full-text is not installed'
             WHEN SERVERPROPERTY('IsFullTextInstalled') = NULL THEN 'Error'
        END AS IsFullTextInstalled,
        CONVERT(CHAR(100), SERVERPROPERTY('SqlCharSet')) AS SqlCharSet,
        CONVERT(CHAR(100), SERVERPROPERTY('SqlCharSetName')) AS SqlCharSetName,
        CONVERT(CHAR(100), SERVERPROPERTY('SqlSortOrder')) AS SqlSortOrderID,
        CONVERT(CHAR(100), SERVERPROPERTY('SqlSortOrderName')) AS SqlSortOrderName
ORDER BY CONVERT(CHAR(100), SERVERPROPERTY('Servername'))  
