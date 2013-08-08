$OdiScmBannerText = get-content "$env:ODI_SCM_HOME\Configuration\Scripts\OdiScmBanner.txt" | out-string
#write-host $("a" * 16000)
#write-host $("a" * 32000)
write-host $OdiScmBannerText