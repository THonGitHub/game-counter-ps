<################################################################################################
Graficky interfejs pre pripocitavanie hodnot slov v hre SCRABBLE.
################################################################################################>
cls

############################## nacitat GUI ######################################

add-type -AssemblyName PresentationFramework
    
    # XAML bol vytvoreny vo Visual Studio
$xamlFile = 'C:\Users\th3882\source\repos\WpfApp4_GameScoreCounter\GameScoreCounter_verzia_s_vyberom_hracov.xaml'
$inputXAML = Get-Content -Path $xamlFile -Raw

    # niektore znaky v XAML subore budu nahradene inymi
$inputXAML = $inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N","N" -replace '^<Win.*','<Window'
[XML]$XAML = $inputXAML
$reader = new-object System.Xml.XmlNodeReader $XAML

    # tu bude XAML subor naloadovany
try{
    $psform = [Windows.Markup.XamlReader]::Load($reader)
}
catch{
    Write-Host $_.Exception
    throw
}

    # vytvorit premenne
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    try{
        Set-Variable -Name "var_$($_.Name)" -Value $psform.FindName($_.Name) -ErrorAction Stop
    }
    Catch{
        Throw
    }
}

    # na konzole zobrazit zoznam vytvorenych premennych
Get-variable var_*


############################### zoznam funkcii ####################################

    # zobrazí sa úvodné okno
Function GUIpoSpusteniSkriptu{

    # vyprazdnit zaznam z predoslej hry zo zosita AktualnaHra
#For($r = 3; $r -le 30; $r++){
#    for($s = 1; $s -le 6;$s++){
#        $WorkSheetAktualnaHra[$r,$s].Value = ''
#    }
#}
    # vynulovat tabulku v zosite Hraci
For($r = 2; $r -le 6; $r++){
    for($s = 2; $s -le 3; $s++){
        $WorkSheetHraci[$r,$s].value = 0
    }
}

    # skryt
$var_Border.visibility = 'hidden'         # ramcek
$var_Hrac1.visibility = 'hidden'          # tlacitko
$var_Hrac2.visibility = 'hidden'          # tlacitko
$var_btnZaciatokHry.visibility = 'hidden' # tlacitko

    # zobrazit
$var_NaTahuJeHrac.Margin = '130,60,0,0'                  # oznamenie
$var_NaTahuJeHrac.content = "Vyber mená hráčov:"
    
    # Funkcia umozni vybrat mena hracov pomocou checkboxov 
VyberMenaHracov

}
    
    # funkcia sa spustí stlačením tlačítka s menom niektorého hráča
    # funkcia zistí a porovná počet víťazstiev počas doterajšej histórie
Function GUIPrehladDoterajsiehoZapolenia {
    
    # skryť
$Status = "hidden"
CheckBoxySmenamiHracov # skryť checkboxy
$var_NaTahuJeHrac.content = ''
$var_NaTahuJeHrac_copy.content = " "
$var_lblZvolHracov.Content = ''
$var_Hrac.visibility = 'hidden'
$var_Hrac1.IsEnabled = $false
$var_Hrac2.IsEnabled = $false

    # zobraziť
$var_StavHry.content = 'Doterajší stav zápolenia:' # nápis
$var_StavHry.visibility = 'visible'
$var_Border.visibility = 'visible'
$var_btnZaciatokHry.visibility = 'visible'         # tlačítko
$var_Hrac.visibility = 'visible'
$var_NaTahuJeHrac.margin = '120,100,0,0'

    # Hrac1 - GUI prehľad doterajších víťazstiev
$var_lblBodySpoluH1.visibility = 'visible'
$var_lblBodySpoluH1.Margin = '223,250,0,0'
$var_lblBodySpoluH1.Content = 'počet víťazstiev'
$var_PriebeznySucet1.visibility = 'visible'
$var_PriebeznySucet1.Margin = '241,276,0,0'

    # Hrac2 - GUI prehľad doterajších víťazstiev
$var_lblBodySpoluH2.visibility = 'visible'
$var_lblBodySpoluH2.Margin = '466,250,0,0'
$var_lblBodySpoluH2.Content = 'počet víťazstiev'
$var_PriebeznySucet2.visibility = 'visible'
$var_PriebeznySucet2.Margin = '484,276,0,0'

    # Podla mien zvolenych hracov definovat Worksheet, do ktoreho sa budu zapisovat 
    # vysledky hry
    # MamkaTati
if(($WorkSheetHraci[2,2].Value -eq 1) -and ($WorkSheetHraci[3,2].Value  -eq 1)){
    $SheetName = $WorkSheetHraci[2,1].value + $WorkSheetHraci[3,1].Value
    if($ExcelPackage.Workbook.Worksheets[$SheetName].Cells){
    $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets[$SheetName].Cells
    }
        # ak poradie zvolenych mien hracov na tlacitkach nezodpoveda poradiu mien v zosite
        # prehodit mena na tlacitkach
    if($var_Hrac1.content -ne $WorkSheetScoreCumul[1,2].value){
       $var_Hrac1.content  = $WorkSheetScoreCumul[1,2].value
       $var_Hrac2.content  = $WorkSheetScoreCumul[1,4].value
    }
}
    # ZuzkaTai
if((($WorkSheetHraci[5,2].Value -eq 1) -and ($WorkSheetHraci[3,2].Value  -eq 1))){
    $SheetName = $WorkSheetHraci[5,1].value + $WorkSheetHraci[3,1].Value
    $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets[$SheetName].Cells
        # ak poradie zvolenych mien hracov na tlacitkach nezodpoveda poradiu mien v zosite
        # prehodit mena na tlacitkach
    if($var_Hrac1.content -ne $WorkSheetScoreCumul[1,2].value){
       $var_Hrac1.content  = $WorkSheetScoreCumul[1,2].value
       $var_Hrac2.content  = $WorkSheetScoreCumul[1,4].value
    }
}

    # ak zvoleni hraci este spolu doteraz nehrali
if((($WorkSheetHraci[2,2].Value -eq 1) -and ($WorkSheetHraci[4,2].Value  -eq 1))){ # -or (($WorkSheetHraci[4,2].Value -eq 1) -and ($WorkSheetHraci[2,3].Value  -eq 1))){
    $SheetName = $WorkSheetHraci[2,1].value + $WorkSheetHraci[4,1].Value
    Write-Host '141 SheetName'$SheetName
        # mamkaTomik
    if(!$WorkSheetScoreCumul){
        VytvoritNovyZosit $SheetName
        Write-Host '145 zosit'$SheetName 'bol vytvoreny'
        $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets[$SheetName].Cells
    }
    else{
        $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets[$SheetName].Cells
    }
}

    # zistit posledny riadok s datumom v zosite ScoreCumulatives 
$PoslRiadokScCum = ZistitPoslednyRiadok $WorkSheetScoreCumul 3 1

    # zo zosita zistit pocet vitazstiev hracov doteraz
$var_PriebeznySucet1.Content = $WorkSheetScoreCumul[($PoslRiadokScCum + 1),3].value
$var_PriebeznySucet2.Content = $WorkSheetScoreCumul[($PoslRiadokScCum + 1),5].value

    # ak je to uplne prva hra novych hhracov
if($var_PriebeznySucet1.Content -eq 0){
    $var_PriebeznySucet1.Content = 0
}
    # ak su to hraci, ktori uz maju zaznamy z predoslych hier
elseif((!$var_PriebeznySucet1.Content)){
    $var_PriebeznySucet1.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),3].value
}
    # zistit, kto ma vyssi pocet vitazstiev
if($var_PriebeznySucet2.Content -eq 0){
    $var_PriebeznySucet2.Content = 0
}
elseif((!$var_PriebeznySucet2.Content)){
    $var_PriebeznySucet2.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),5].value
}
        # zelene pozadie pre hraca s vyssim poctom vitazstiev
if($var_PriebeznySucet1.Content -gt $var_PriebeznySucet2.Content){
    $var_Hrac.Content = $var_Hrac1.Content # meno hraca s vyssim poctom vitazstiev doteraz
    $var_Hrac.Margin = '380,100,0,0'
    $var_NaTahuJeHrac.Content = 'Víťaz predošlého kola:'
    $var_PriebeznySucet1.Background = '#00FF00'
}
elseif($var_PriebeznySucet1.Content -lt $var_PriebeznySucet2.Content){
    $var_Hrac.Content = $var_Hrac2.Content # meno hraca s vyssim poctom vitazstiev doteraz
    $var_Hrac.Margin = '380,100,0,0'
    $var_NaTahuJeHrac.Content = 'Víťaz predošlého kola:'
    $var_PriebeznySucet2.Background = '#00FF00'
}
else{
    $var_NaTahuJeHrac.Content = 'Výsledkom predošlého kola bola'
    $var_Hrac.Content = 'remíza'
    $var_Hrac.Margin = '410,98,0,0'
    $var_NaTahuJeHrac.margin = '62,100,0,0'
}
  
$var_Hrac.Background = '#FFFAC4FD'    # pozadie pola s meno vitaza z predoslej hry

#$var_NaTahuJeHrac.margin = '62,100,0,0'
}

Function VytvoritNovyZosit($SheetName){
    $GameFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter_verzia_s_vyberom_hracov - Copy.xlsx"
    Close-ExcelPackage $ExcelPackage
    Copy-ExcelWorksheet -SourceWorkBook $GameFile -SourceWorksheet 'ZdrojKumul' -DestinationWorkbook $GameFile -DestinationWorksheet $SheetName
    $ExcelPackage = Open-ExcelPackage $GameFile # open excel package
}

    # zistit v zosite cislo posledne pouziteho riadku,
Function ZistitPoslednyRiadok($WorkSheetZPR,$RowZPR,$ColumnZPR){
    while($WorkSheetZPR[$RowZPR,$ColumnZPR].Value){
        $RowZPR++
    }
    Return ($RowZPR - 1)
}

    # vlozit data do bunky zosita 
Function DataDoBunky ($WorkSheetDDB,$RowDDB,$ColumnDDB,$ValueDDB){
    
    if($WorkSheetDDB -eq $WorkSheetAktualnaHra){
    set-format -address $ExcelPackage.Workbook.Worksheets['CurrentScore'].cells[$rowDDB,$ColumnDDB] -HorizontalAlignment Center
    }
    elseif($WorkSheetDDB -eq $WorkSheetScoreCumul){
        set-format -address $ExcelPackage.Workbook.Worksheets['ScoreCumulatives'].cells[$rowDDB,$ColumnDDB] -HorizontalAlignment Center -BorderAround Thin
    }
    $WorkSheetDDB[$rowDDB,$ColumnDDB].value = $ValueDDB
}

    # zobrazit/skryt checkboxy s menami hracov
Function CheckBoxySmenamiHracov{
   
$var_chkElzička.visibility = $Status
$var_chkTomáš.visibility = $Status
$var_chkTomik.visibility = $Status
$var_chkZuzanka.visibility = $Status
$var_chkTimko.visibility = $Status
}

    # zo zosita Hraci zistit mena hracov v prvom stlpci
Function ZistitMenaHracov{
$Hraci = @() # array s menami hracov, ktor su v zosite Hraci
$i = 2       # cislo riadku, v ktorom zacinaju mena (prvy stlpec)
for($i = 2; $i -le ($PocetHracov + 1); $i++){
    $Hrac = $WorkSheetHraci[$i,1].value
    $Hraci += $Hrac
}
Return $Hraci
}

    # vybrat mena hracov pomocou checkboxov
Function VyberMenaHracov{

    # zavolat funkciu na zistenie existujucich mien hracov v zosite Hraci    
$var_Hrac = ZistitMenaHracov
$i = 0

#foreach($Hrac in $var_Hrac){
#    $Hrac = 'Hrac' + ($i+1)
#    $Hrac + ' = ' + $var_Hrac[$i]
#    $i++
#}
$checkCounter = 0
$var_RowXLSX.Content = 0

$var_chkElzička.Add_Checked({
    # zvacsit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter + 1
$var_RowXLSX.Content = $checkCounter
    
    # ak je tlacitko Hrac1 prazdne, vloz don meno hraca
if($var_Hrac1.Content -eq ''){
    $var_Hrac1.Visibility = 'visible'
    $var_Hrac1.Content = $var_chkElzička.Content
}    
    # ak je tlacitko Hrac1 obsadene, vloz meno hraca do tlacitka Hrac2
else{
    $var_Hrac2.Visibility = 'visible'
    $var_Hrac2.Content = $var_chkElzička.Content
}
    
    # deaktivovat zvysne checkboxy
if(($var_RowXLSX.Content -eq 2) -and (($var_Hrac1.Content -eq $var_chkElzička.Content) -or ($var_Hrac2.Content -eq $var_chkElzička.Content))){
    if(($var_Hrac1.Content -eq $var_chkTomáš.Content) -or ($var_Hrac2.Content -eq $var_chkTomáš.Content)){
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomik.Content) -or ($var_Hrac2.Content -eq $var_chkTomik.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkZuzanka.Content) -or ($var_Hrac2.Content -eq $var_chkZuzanka.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTimko.Content) -or ($var_Hrac2.Content -eq $var_chkTimko.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
    }
}
DataDoBunky $WorkSheetHraci 2 2 1
})
$var_chkElzička.Add_UnChecked({
    # zmensit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter - 1
$var_RowXLSX.Content = $checkCounter

    # ak je meno hraca v tlacitku Hrac1, vyjmi ho
if($var_Hrac1.Content -eq $var_chkElzička.Content){   
    $var_Hrac1.Content = ''
    $var_Hrac1.visibility = 'hidden'

}
    # ak je meno hraca v tlacitku Hrac2, vyjmi ho
else{
    $var_Hrac2.Content = ''
    $var_Hrac2.visibility = 'hidden'
}
    # aktivuj vsetky checkboxy
if($var_RowXLSX.Content -lt 2){
    $var_chkElzička.IsEnabled = $True
    $var_chkTomáš.IsEnabled = $True
    $var_chkTomik.IsEnabled = $True
    $var_chkZuzanka.IsEnabled = $True
    $var_chkTimko.IsEnabled = $True
}
DataDoBunky $WorkSheetHraci 2 2 0
})

$var_chkTomáš.Add_Checked({
    # zvacsit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter + 1
$var_RowXLSX.Content = $checkCounter
    
    # ak je tlacitko Hrac1 prazdne, vloz don meno hraca
if($var_Hrac1.Content -eq ''){
    $var_Hrac1.Visibility = 'visible'
    $var_Hrac1.Content = $var_chkTomáš.Content
}    
    # ak je tlacitko Hrac1 obsadene, vloz meno hraca do tlacitka Hrac2
else{
    $var_Hrac2.Visibility = 'visible'
    $var_Hrac2.Content = $var_chkTomáš.Content
}
    
    # deaktivovat zvysne checkboxy
if(($var_RowXLSX.Content -eq 2) -and (($var_Hrac1.Content -eq $var_chkTomáš.Content) -or ($var_Hrac2.Content -eq $var_chkTomáš.Content))){
    if(($var_Hrac1.Content -eq $var_chkElzička.Content) -or ($var_Hrac2.Content -eq $var_chkElzička.Content)){
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomik.Content) -or ($var_Hrac2.Content -eq $var_chkTomik.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkZuzanka.Content) -or ($var_Hrac2.Content -eq $var_chkZuzanka.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTimko.Content) -or ($var_Hrac2.Content -eq $var_chkTimko.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkzuzanka.IsEnabled = $False
    }
}
DataDoBunky $WorkSheetHraci 3 2 1
})
$var_chkTomáš.Add_UnChecked({
    # zmensit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter - 1
$var_RowXLSX.Content = $checkCounter

    # ak je meno hraca v tlacitku Hrac1, vyjmi ho
if($var_Hrac1.Content -eq $var_chkTomáš.Content){   
    $var_Hrac1.Content = ''
    $var_Hrac1.visibility = 'hidden'

}
    # ak je meno hraca v tlacitku Hrac2, vyjmi ho
else{
    $var_Hrac2.Content = ''
    $var_Hrac2.visibility = 'hidden'
}
    # aktivuj vsetky checkboxy
if($var_RowXLSX.Content -lt 2){
    $var_chkElzička.IsEnabled = $True
    $var_chkTomáš.IsEnabled = $True
    $var_chkTomik.IsEnabled = $True
    $var_chkZuzanka.IsEnabled = $True
    $var_chkTimko.IsEnabled = $True
}
DataDoBunky $WorkSheetHraci 3 2 0
})


$var_chkTomik.Add_Checked({
    # zvacsit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter + 1
$var_RowXLSX.Content = $checkCounter
    
    # ak je tlacitko Hrac1 prazdne, vloz don meno hraca
if($var_Hrac1.Content -eq ''){
    $var_Hrac1.Visibility = 'visible'
    $var_Hrac1.Content = $var_chkTomik.Content
}
    
    # ak je tlacitko Hrac1 obsadene, vloz meno hraca do tlacitka Hrac2
else{
    $var_Hrac2.Visibility = 'visible'
    $var_Hrac2.Content = $var_chkTomik.Content
}
    
    # deaktivovat zvysne checkboxy
if(($var_RowXLSX.Content -eq 2) -and (($var_Hrac1.Content -eq $var_chkTomik.Content) -or ($var_Hrac2.Content -eq $var_chkTomik.Content))){
    if(($var_Hrac1.Content -eq $var_chkElzička.Content) -or ($var_Hrac2.Content -eq $var_chkElzička.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomáš.Content) -or ($var_Hrac2.Content -eq $var_chkTomáš.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkZuzanka.Content) -or ($var_Hrac2.Content -eq $var_chkZuzanka.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTimko.Content) -or ($var_Hrac2.Content -eq $var_chkTimko.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
    }
}
DataDoBunky $WorkSheetHraci 4 2 1
})
$var_chkTomik.Add_UnChecked({

    # zmensit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter - 1
$var_RowXLSX.Content = $checkCounter

    # ak je meno hraca v tlacitku Hrac1, vyjmi ho
if($var_Hrac1.Content -eq $var_chkTomik.Content){   
    $var_Hrac1.Content = ''
    $var_Hrac1.visibility = 'hidden'

}
    # ak je meno hraca v tlacitku Hrac2, vyjmi ho
else{
    $var_Hrac2.Content = ''
    $var_Hrac2.visibility = 'hidden'
}
    # aktivuj vsetky checkboxy
if($var_RowXLSX.Content -lt 2){
    $var_chkElzička.IsEnabled = $True
    $var_chkTomáš.IsEnabled = $True
    $var_chkTomik.IsEnabled = $True
    $var_chkZuzanka.IsEnabled = $True
    $var_chkTimko.IsEnabled = $True
}
DataDoBunky $WorkSheetHraci 4 2 0
})

$var_chkZuzanka.Add_Checked({

    # zvacsit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter + 1
$var_RowXLSX.Content = $checkCounter
    
    # ak je tlacitko Hrac1 prazdne, vloz don meno hraca
if($var_Hrac1.Content -eq ''){
    $var_Hrac1.Visibility = 'visible'
    $var_Hrac1.Content = $var_chkZuzanka.Content
}
    
    # ak je tlacitko Hrac1 obsadene, vloz meno hraca do tlacitka Hrac2
else{
    $var_Hrac2.Visibility = 'visible'
    $var_Hrac2.Content = $var_chkZuzanka.Content
}
    
    # deaktivovat zvysne checkboxy
if(($var_RowXLSX.Content -eq 2) -and (($var_Hrac1.Content -eq $var_chkZuzanka.Content) -or ($var_Hrac2.Content -eq $var_chkZuzanka.Content))){
    if(($var_Hrac1.Content -eq $var_chkElzička.Content) -or ($var_Hrac2.Content -eq $var_chkElzička.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomáš.Content) -or ($var_Hrac2.Content -eq $var_chkTomáš.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomik.Content) -or ($var_Hrac2.Content -eq $var_chkTomik.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTimko.Content) -or ($var_Hrac2.Content -eq $var_chkTimko.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
    }
}
DataDoBunky $WorkSheetHraci 5 2 1
})
$var_chkZuzanka.Add_UnChecked({

    # zmensit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter - 1
$var_RowXLSX.Content = $checkCounter

    # ak je meno hraca v tlacitku Hrac1, vyjmi ho
if($var_Hrac1.Content -eq $var_chkZuzanka.Content){   
    $var_Hrac1.Content = ''
    $var_Hrac1.visibility = 'hidden'

}
    # ak je meno hraca v tlacitku Hrac2, vyjmi ho
else{
    $var_Hrac2.Content = ''
    $var_Hrac2.visibility = 'hidden'
}
    # aktivuj vsetky checkboxy
if($var_RowXLSX.Content -lt 2){
    $var_chkElzička.IsEnabled = $True
    $var_chkTomáš.IsEnabled = $True
    $var_chkTomik.IsEnabled = $True
    $var_chkZuzanka.IsEnabled = $True
    $var_chkTimko.IsEnabled = $True
}
DataDoBunky $WorkSheetHraci 5 2 0
})

$var_chkTimko.Add_Checked({

    # zvacsit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter + 1
$var_RowXLSX.Content = $checkCounter
    
    # ak je tlacitko Hrac1 prazdne, vloz don meno hraca
if($var_Hrac1.Content -eq ''){
    $var_Hrac1.Visibility = 'visible'
    $var_Hrac1.Content = $var_chkTimko.Content
}
    
    # ak je tlacitko Hrac1 obsadene, vloz meno hraca do tlacitka Hrac2
else{
    $var_Hrac2.Visibility = 'visible'
    $var_Hrac2.Content = $var_chkTimko.Content
}
    
    # deaktivovat zvysne checkboxy
if(($var_RowXLSX.Content -eq 2) -and (($var_Hrac1.Content -eq $var_chkTimko.Content) -or ($var_Hrac2.Content -eq $var_chkTimko.Content))){
    if(($var_Hrac1.Content -eq $var_chkElzička.Content) -or ($var_Hrac2.Content -eq $var_chkElzička.Content)){
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomáš.Content) -or ($var_Hrac2.Content -eq $var_chkTomáš.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkZuzanka.Content) -or ($var_Hrac2.Content -eq $var_chkZuzanka.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
    }
    elseif(($var_Hrac1.Content -eq $var_chkTomik.Content) -or ($var_Hrac2.Content -eq $var_chkTomik.Content)){
        $var_chkElzička.IsEnabled = $False
        $var_chkTomáš.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
    }
}
DataDoBunky $WorkSheetHraci 6 2 1
})
$var_chkTimko.Add_UnChecked({

    # zmensit pocitadlo poctu hracov o 1
$checkCounter = $var_RowXLSX.Content
$checkCounter = $checkCounter - 1
$var_RowXLSX.Content = $checkCounter

    # ak je meno hraca v tlacitku Hrac1, vyjmi ho
if($var_Hrac1.Content -eq $var_chkTimko.Content){   
    $var_Hrac1.Content = ''
    $var_Hrac1.visibility = 'hidden'

}
    # ak je meno hraca v tlacitku Hrac2, vyjmi ho
else{
    $var_Hrac2.Content = ''
    $var_Hrac2.visibility = 'hidden'
}
    # aktivuj vsetky checkboxy
if($var_RowXLSX.Content -lt 2){
    $var_chkElzička.IsEnabled = $True
    $var_chkTomáš.IsEnabled = $True
    $var_chkTomik.IsEnabled = $True
    $var_chkZuzanka.IsEnabled = $True
    $var_chkTimko.IsEnabled = $True
}
DataDoBunky $WorkSheetHraci 6 2 0
})
}


#################### aktivovat excel package ####################
$GameFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter_verzia_s_vyberom_hracov - Copy.xlsx"
$ExcelPackage = Open-ExcelPackage $GameFile # open excel package
$WorkSheetHraci = $ExcelPackage.Workbook.Worksheets['Hraci'].Cells
$WorkSheetAktualnaHra = $ExcelPackage.Workbook.Worksheets['AktualnaHra'].Cells
$PocetHracov = (ZistitPoslednyRiadok $WorkSheetHraci 2 1) -1
write-host '534 PocetHracov' $PocetHracov
GUIpoSpusteniSkriptu

<###################### ZACIATOK HRY ########################
 Stlacenim tlacitka s menom niektoreho hraca treba rozhodnut, 
 kto hru zacina - zaroven sa zvyrazni meno zacinajuceho hraca
#############################################################>

$var_Hrac1.Add_Click({    
    #$var_Hrac.Content = $var_Hrac1.Content
    GUIPrehladDoterajsiehoZapolenia

})
$var_Hrac2.Add_Click({
    #$var_Hrac.Content = $var_Hrac2.Content
    GUIPrehladDoterajsiehoZapolenia
})



####################### zobrazit GUI #########################
$psform.ShowDialog()

########### zavriet Excel package a zobrazit excel ###########
Close-ExcelPackage $ExcelPackage #-Show
