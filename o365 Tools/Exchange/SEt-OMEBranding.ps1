Get-OMEConfiguration | fl

Set-OMEConfiguration -Identity "OME Configuration" -Image (Get-Content "C:\logos\logo.png" -Encoding byte) 

Set-OMEConfiguration -Identity "OME Configuration" -BackgroundColor "#F39C12" `
    -DisclaimerText "This email is only intended for the addressed recipient. Attempting to access the encryped email with an unauthorised account or permission is against the rules, and will not work anyway! For more information see Information Link." `
    -Image (Get-Content "C:\logos\Logo.jpg" -Encoding byte) `
    -EmailText "You have been sent an email that has been encrypted. You will need to validate your identity in order to access the content of the message." `
    -IntroductionText "has sent you an encrypted email. Please verify your identity at the link below to access the encrypted email." `
    -OTPEnabled:$True -PortalText "M365LAB Office 365 Message Encryption Portal" -ReadButtonText "View encrypted email" -SocialIDSignIn:$True