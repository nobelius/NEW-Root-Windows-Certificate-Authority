### ROOT OFFLINE CA ###

#Run PS as Administrator
$credential = Get-Credential
$webname = "crl.nobelius.net"
$ADNAME = "ad.nobelius.local"


# Create CApolicy file


### CHANGE THE URL Below! ###

Set-Content c:\Windows\CApolicy.inf `
'[Version]
Signature="$Windows NT$"
[PolicyStatementExtension]
Policies=InternalPolicy
[InternalPolicy]
URL=http://crl.nobelius.net/pki/cps.html
[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=20
CRLPeriod=Years
CRLPeriodUnits=20
CRLDeltaPeriod=Days
CRLDeltaPeriodUnits=0
LoadDefaultTemplates=0'



#install CA role

### Change (-CACommonName) below as well ###

Get-WindowsFeature Adcs-Cert-Authority| Install-WindowsFeature -IncludeManagementTools
Install-AdcsCertificationAuthority `
-Credential $credential `
-CAType StandaloneRootCa `
-CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
-KeyLength 2048 `
-HashAlgorithmName SHA256 `
-ValidityPeriod Years `
-ValidityPeriodUnits 20 `
-CACommonName "Nobelius-CA" `
-LogDirectory "C:\Windows\system32\CertLog" `
-Confirm:$false

start-sleep 10

Remove-CACrlDistributionPoint -Uri "http://<ServerDNSName>/CertEnroll/<CAName><CRLNameSuffix><DeltaCRLAllowed>.crl" -Force
Remove-CACrlDistributionPoint -Uri "file://<ServerDNSName>/CertEnroll/<CAName><CRLNameSuffix><DeltaCRLAllowed>.crl" -Force
Add-CACRLDistributionPoint -Uri "http://$webname/<CaName><CRLNameSuffix><DeltaCRLAllowed>.crl" -AddToCertificateCdp -AddToFreshestCrl -Force


http://crl.domain.com/CertEnroll/<ServerDNSName>_<CaName><CertificateName>.crt

certutil -setreg CACRLPeriod Years
certutil -setreg CACRLPeriodUnits 20
Certutil -setreg CAValidityPeriodUnits 10
Certutil -setreg CAValidityPeriod "Years"
