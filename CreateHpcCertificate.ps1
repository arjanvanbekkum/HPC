﻿.  "C:\ProgramData\WriteToLog.ps1"

$CommonName = "HPC Pack 2016 Communication"
$Path = "C:\ProgramData\HPCCertificate.pfx"
$password = aws ssm get-parameter --name "/certificate/hpc/password" --query "Parameter.Value" --with-decryption --output text --region eu-central-1
$password = $password | ConvertTo-SecureString -AsPlainText -Force

$startDate = Get-Date
# GENERATE self signed certificate
$name = new-object -com X509Enrollment.CX500DistinguishedName
$name.Encode("CN=$CommonName", 0)

# http://msdn.microsoft.com/en-us/library/aa378921(VS.85).aspx
$key = new-object -com X509Enrollment.CX509PrivateKey
$key.ProviderName = "Microsoft Enhanced Cryptographic Provider v1.0"
# KeySpec 1 for Exchange
$key.KeySpec = 1
$key.Length = 2048
# ExportPolicy 1 for Exportable
$key.ExportPolicy = 1
# True for LocalMachine, and False for CurrentUser
$key.MachineContext = $false
$key.Create()

# KeyUsage:
$KU = New-Object -ComObject X509Enrollment.CX509ExtensionKeyUsage
$KU.InitializeEncode([Security.Cryptography.X509Certificates.X509KeyUsageFlags]::DigitalSignature -bor [Security.Cryptography.X509Certificates.X509KeyUsageFlags]::KeyEncipherment)
$KU.Critical = $true
$ExtensionsToAdd += "KU"

# EnhancedKeyUsage: Server Authentication and client Authentication
$serverauthoid = new-object -com X509Enrollment.CObjectId
$serverauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.1")
$clientauthoid = new-object -com X509Enrollment.CObjectId
$clientauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.2")
$ekuoids = new-object -com X509Enrollment.CObjectIds
$ekuoids.add($serverauthoid)
$ekuoids.add($clientauthoid)
$ekuext = new-object -com "X509Enrollment.CX509ExtensionEnhancedKeyUsage"
$ekuext.InitializeEncode($ekuoids)

$sigoid = New-Object -ComObject X509Enrollment.CObjectId
$sigoid.InitializeFromValue(([Security.Cryptography.Oid]"SHA256").Value)

# Generate the request
$cert = new-object -com "X509Enrollment.CX509CertificateRequestCertificate"
$cert.InitializeFromPrivateKey(1, $key, "")
$cert.Subject = $name
$cert.Issuer = $cert.Subject
$cert.NotBefore = $startDate.AddDays(-1)
$cert.NotAfter = $startDate.AddYears(5)

$cert.X509Extensions.Add($KU)
$cert.X509Extensions.Add($ekuext)
$cert.SignatureInformation.HashAlgorithm = $sigoid
$cert.Encode()

$enrollment = new-object -com "X509Enrollment.CX509Enrollment"
$enrollment.InitializeFromRequest($cert)
$certdata = $enrollment.CreateRequest(1)
$cerBytes = [System.Convert]::FromBase64String($certdata)
$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cer.Import($cerBytes)
$thumbprint = $cer.Thumbprint
$enrollment.InstallResponse(2, $certdata, 1, "")
$PFXString = $enrollment.CreatePFX([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)), 0)
Set-Content -Path $Path -Value ([Convert]::FromBase64String($PFXString)) -Encoding Byte
# Remove the certificate from Cert:\CurrentUser\My\$thumbprint store
Remove-Item Cert:\CurrentUser\My\$thumbprint -Confirm:$false -Force

# SIG # Begin signature block
# MIIdhwYJKoZIhvcNAQcCoIIdeDCCHXQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSzX4eISWBPsh5L1yiQ2DePuw
# eaigghhjMIIE3jCCA8agAwIBAgITMwAAAOtpqsw+KZ8tOQAAAAAA6zANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTgwODIzMjAxOTMw
# WhcNMTkxMTIzMjAxOTMwWjCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJp
# Y28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkI4RUMtMzBBNC03MTQ0MSUwIwYD
# VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAtUgVMTCRT4OJO0Mpuwvx+XO5QmP3h0rKAKfeLGh8
# EaWmLrpncRID7XmyosZLraSDHoz/hauMvlnCJFE+iMTvTDkSiioNZcAKBK7JDIq0
# vPzA559v2UunwBHaU+NueS6nYTBx54n6I4QpiE8/wr3dMz4e10eBAXd8h4OZ4ZK/
# YmJfSxJUGMSn70yzmSuKhQ7tIqUmmUSIt2Z3vu/zRhbKi8Aind4+ASRFpYMuE+1h
# D4jIpwJ1CUjZZhI0UsDRa7mz6CO2RwCUXPRjgXXvTfrv2zv+F8jDbTfEXs8RZPLw
# 3eIFo06gqUfYhp1Ufw+/7Oesc5rM4OkRY1TG2jD/ne5PqQIDAQABo4IBCTCCAQUw
# HQYDVR0OBBYEFAW30KaPfAOZ1HwiXZI8utZ3J6amMB8GA1UdIwQYMBaAFCM0+NlS
# RnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly9jcmwubWlj
# cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY3Jvc29mdFRpbWVTdGFtcFBD
# QS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsGAQUFBzAChjxodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcnQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQEFBQADggEBAHvg1mBCSvjq
# wnWpRZF0s84/duMABrGAur2JSbcCMVeY1Gz9xftubwtIkxaUSqtyUkGOJVdgwlUM
# ZAT4/up2bRT896uVKcEHNweSFLqPxfeJFgsUzQ+z9ftH4S9+IX+V7o0HB4VoB92Q
# 9Qdd56HqRJFaLzbsppXJpSXbbdtrBjjfohYSrkzlcedWQ6sANjswlYbZ4cWxGDEB
# 3ad8YTzLnPZtcwY4R4n49UOnUavG/NB0tJRUbMOO4fyUAMBr4R20tYudgvoXRK8B
# VVEfYP6mQa1QG6Mh3oluJb3jJ7pYpDfMMRXh3S9Y6pofu67todxbL7afn1Vi11d6
# /bjN6QMHSnYwggX0MIID3KADAgECAhMzAAABUMiPlnfeTPFHAAAAAAFQMA0GCSqG
# SIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwHhcNMTkw
# NTAyMjEzNzQ1WhcNMjAwNTAyMjEzNzQ1WjB0MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNyb3NvZnQgQ29ycG9yYXRpb24w
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCh2V193EGtu49awDgcJ1E8
# WB5mAim/gAFVpWUVOlk/haZWAiffh/k3W/GPhgYlt2WH/FQS4BcGpeWRb2Wi4seO
# UWb5lbgIuUKBORF0iiEiPNMLueuD3PAChl/h3WE2N1T8zsQg6UMrWtNRdby48xCI
# 6zdD+26yNei3tOccrOWWullOehpBF5Z4vp8Xvq1nysaSkGgAZNaKrb3F6et3V5Tq
# +gJ0DaLm/TGxATcTJ1mrHJOx+cHorSIeGKKzwa19uBuUbGALZx8Isus+3KiK7h2Y
# cZ+AHU+qeUCLbKhU3l97Kg9E6/dvAMa+42/BXSmZ9+F3WfagixcbNWGaZA1Pn8mP
# AgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEEAYI3TAgBBggrBgEFBQcDAzAd
# BgNVHQ4EFgQUGxNB+9SPshuMPQ+xlMnFMiKVkDgwRQYDVR0RBD4wPKQ6MDgxHjAc
# BgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEWMBQGA1UEBRMNMjMwMDEyKzQ1
# NDEzNDAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBL
# MEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWND
# b2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggr
# BgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9N
# aWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJ
# KoZIhvcNAQELBQADggIBADSrnbMt49ZGUc9KnW7SVkzITe55ApMwgxE8jl06lBkM
# ZLd9QatyUt6g2/0RG0boaMHpWzypk6pGDLRD5y/P6sj6fQYkrGihAw3W4ObLE3rr
# Y8e5GPTrp/AlMFzsywHhD0+ETwgU8PuMvwQfB6ak2ejWP0M1a1tkyAHfEMEGKd7R
# VPRmlLX+kPkJoFPz/uSlKxXi/acGH1qISQc0pkRtUE/ufrfpR+LlEOPg5aNZdAwI
# JAuDWInMeQM7kIoUTShSAJTzT58mrwVXgrfBbZnANpsC/v8/amGL43MhTN0V2sWB
# HZNL7N0X9Z2qldu+jj8HdaNRGQyuru1W+IjNV914nk3qp9T/bZmy0elNYkCdNFja
# pARu6TZ0wwlEkvFW0HuzwtQ2gGDddGuhRFQRrdbU68ifXf3dtvUDb0Nr+tnw9k0m
# V4s9jkTraDBaSJV0v1ixeR6WEBgGcc+uL/rHnci89cMcZqqcY8gGw0T1GpdDbWYL
# sYsqfPu5ZP4ga0kZa/ne7Bi3zu8XZ72kM893t5IbZ96/2xp2Q+I6vIVfZJ7fh7vQ
# 3OcLAZDvN+y6jNq3jtnQSYHuhX+Du074DXhQeVTBqTzBiuZPbnJhmI525u1GVoGe
# mw0fqwk4cpeh3d1cDMN5eWlmqEdRwgaWozpj3a4IBzxVWkDJSJ4ZEq2odtK6eoYc
# MIIGBzCCA++gAwIBAgIKYRZoNAAAAAAAHDANBgkqhkiG9w0BAQUFADBfMRMwEQYK
# CZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYD
# VQQDEyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDcw
# NDAzMTI1MzA5WhcNMjEwNDAzMTMwMzA5WjB3MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQ
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCfoWyx39tIkip8ay4Z
# 4b3i48WZUSNQrc7dGE4kD+7Rp9FMrXQwIBHrB9VUlRVJlBtCkq6YXDAm2gBr6Hu9
# 7IkHD/cOBJjwicwfyzMkh53y9GccLPx754gd6udOo6HBI1PKjfpFzwnQXq/QsEIE
# ovmmbJNn1yjcRlOwhtDlKEYuJ6yGT1VSDOQDLPtqkJAwbofzWTCd+n7Wl7PoIZd+
# +NIT8wi3U21StEWQn0gASkdmEScpZqiX5NMGgUqi+YSnEUcUCYKfhO1VeP4Bmh1Q
# CIUAEDBG7bfeI0a7xC1Un68eeEExd8yb3zuDk6FhArUdDbH895uyAc4iS1T/+QXD
# wiALAgMBAAGjggGrMIIBpzAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQjNPjZ
# UkZwCu1A+3b7syuwwzWzDzALBgNVHQ8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAw
# gZgGA1UdIwSBkDCBjYAUDqyCYEBWJ5flJRP8KuEKU5VZ5KShY6RhMF8xEzARBgoJ
# kiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNV
# BAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eYIQea0WoUqg
# pa1Mc1j0BxMuZTBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29m
# dC5jb20vcGtpL2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYI
# KwYBBQUHAQEESDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDATBgNVHSUEDDAKBggr
# BgEFBQcDCDANBgkqhkiG9w0BAQUFAAOCAgEAEJeKw1wDRDbd6bStd9vOeVFNAbEu
# dHFbbQwTq86+e4+4LtQSooxtYrhXAstOIBNQmd16QOJXu69YmhzhHQGGrLt48ovQ
# 7DsB7uK+jwoFyI1I4vBTFd1Pq5Lk541q1YDB5pTyBi+FA+mRKiQicPv2/OR4mS4N
# 9wficLwYTp2OawpylbihOZxnLcVRDupiXD8WmIsgP+IHGjL5zDFKdjE9K3ILyOpw
# Pf+FChPfwgphjvDXuBfrTot/xTUrXqO/67x9C0J71FNyIe4wyrt4ZVxbARcKFA7S
# 2hSY9Ty5ZlizLS/n+YWGzFFW6J1wlGysOUzU9nm/qhh6YinvopspNAZ3GmLJPR5t
# H4LwC8csu89Ds+X57H2146SodDW4TsVxIxImdgs8UoxxWkZDFLyzs7BNZ8ifQv+A
# eSGAnhUwZuhCEl4ayJ4iIdBD6Svpu/RIzCzU2DKATCYqSCRfWupW76bemZ3KOm+9
# gSd0BhHudiG/m4LBJ1S2sWo9iaF2YbRuoROmv6pH8BJv/YoybLL+31HIjCPJZr2d
# HYcSZAI9La9Zj7jkIeW1sMpjtHhUBdRBLlCslLCleKuzoJZ1GtmShxN1Ii8yqAhu
# oFuMJb+g74TKIdbrHk/Jmu5J4PcBZW+JC33Iacjmbuqnl84xKf8OxVtc2E0bodj6
# L54/LlUWa8kTo/0wggd6MIIFYqADAgECAgphDpDSAAAAAAADMA0GCSqGSIb3DQEB
# CwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMTAe
# Fw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDlaMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCr
# 8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgGOBoESbp/wwwe3TdrxhLYC/A4
# wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S35tTsgosw6/ZqSuuegmv15ZZ
# ymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jzy23zOlyhFvRGuuA4ZKxuZDV4
# pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/74ytaEB9NViiienLgEjq3SV7Y
# 7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2uM1jFtz7+MtOzAz2xsq+SOH7S
# nYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33X/DQUr+MlIe8wCF0JV8YKLbM
# Jyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIlXdMhSz5SxLVXPyQD8NF6Wy/V
# I+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP6SNJvBi4RHxF5MHDcnrgcuck
# 379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLBl4F77dbtS+dJKacTKKanfWeA
# 5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGFRInECUzF1KVDL3SV9274eCBY
# LBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiMCwIDAQABo4IB7TCCAekwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQBdOCqhc3NyK1bajKdQKVMBkG
# CSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8E
# BTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO4eqnxzHRI4k0MFoGA1UdHwRT
# MFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18yMi5jcmwwXgYIKwYBBQUHAQEE
# UjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18yMi5jcnQwgZ8GA1UdIASBlzCB
# lDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNwcy5odG0wQAYIKwYBBQUHAgIw
# NB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkAXwBzAHQAYQB0AGUAbQBlAG4A
# dAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY4FR5Gi7T2HRnIpsLlhHhY5KZ
# QpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj82nbY78iNaWXXWWEkH2LRlBV
# 2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUdd5Q54ulkyUQ9eHoj8xN9ppB0
# g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJYx8JaW5amJbkg/TAj/NGK978
# O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYfwzIY4vDFLc5bnrRJOQrGCsLG
# ra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJaG5vp7d0w0AFBqYBKig+gj8T
# TWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1jNpeG39rz+PIWoZon4c2ll9Du
# XWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9Bxw4o7t5lL+yX9qFcltgA1qFG
# vVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96eiL6SJUfq/tHI4D1nvi/a7dL
# l+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7r/ww7QRMjt/fdW1jkT3RnVZO
# T7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5IRcBCyZt2WwqASGv9eZ/BvW1t
# aslScxMNelDNMYIEjjCCBIoCAQEwgZUwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQ
# Q0EgMjAxMQITMwAAAVDIj5Z33kzxRwAAAAABUDAJBgUrDgMCGgUAoIGiMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBTMy0U3iHvZ4hTrH+NVYU+5GmfJ2zBCBgorBgEE
# AYI3AgEMMTQwMqAUgBIATQBpAGMAcgBvAHMAbwBmAHShGoAYaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAHNQn57mXQOo5lWsWuCpbfU9
# nzJTrfps/KWsOT2nEWyoMD2PSNk2YiFVlGdz1xvVIwnfJ0uRg4IffFi3648aXKC2
# eUtBYzb2gw1C3csafA801tUco5shpe2M4CTbBsd2WdpnCb7p9QGCnq5t9XjuzMi+
# ME0bVEqpVlDj0yZM7/4g546KTulyaonoVsHZzGfGiFHGZ/J/15uqN2PDU+MiWZHj
# yHfadyYt8nAYIxiowOeDeQQr5SoMhArACDFCNNRgOn5RhY3MIBSATXou0dSnCmqt
# fQRwIJBAMPUrmydQXnWxcZrgpg0YmmjzE0Kfxc9NXBmSeLzDIDi+iAx/kZJd+oGh
# ggIoMIICJAYJKoZIhvcNAQkGMYICFTCCAhECAQEwgY4wdzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBAhMzAAAA62mqzD4pny05AAAAAADrMAkGBSsOAwIaBQCgXTAYBgkq
# hkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xOTA3MzExODQy
# MDVaMCMGCSqGSIb3DQEJBDEWBBQbgRT1fLtZYTY23L4ELxVcQPCwOTANBgkqhkiG
# 9w0BAQUFAASCAQBoGIQxEJTiU68cfRkLzYGzIVZX4dvTHO9/PPdZqVeuBNxy20xX
# 2MSeV1ZYMfYsaF/7fL8m2+CsJWf1Qo57sH4BLu1L9m6LSbw/P4OGb7O2BSkwoITs
# HKCz+Ji2PLTqxLeL33JVR6os40miNgxdknzKSXTQMy+Sw1o3pifPcyFLlfIBX3RG
# bNpA/nztvswYm5Me+B0pSEaOIvY5lqlTUVBwtRbjDt0ZM8Kv6O4crkn8BPv3cd/z
# yoRZi6l3CJbSEGIM4AR9qP6P3zwx4y2CNC3gJwY371G5MQF6/8u31n51wY0Vr8Ye
# w20HxHRqqMQs+NXj8+93hFKfYIhxNTagoNhj
# SIG # End signature block
