<################################################################################################
Graficky interfejs pre pripocitavanie hodnot slov v hre SCRABBLE.
################################################################################################>
cls

############################## nacitat GUI ######################################

add-type -AssemblyName PresentationFramework
    
    # XAML bol vytvoreny vo Visual Studio
$xamlFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter.xaml"
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

    # definovanie pociatocnych stavov premennych
Function GUIpoSpusteniSkriptu{

    # vyprazdnit zaznam z predoslej hry zo zosita CurrentScore
For($r = 3; $r -le 30; $r++){
    for($s = 1; $s -le 6;$s++){
        $WorkSheetAktualnaHra[$r,$s].Value = ''
    }
}

DataDoBunky $WorkSheetAktualnaHra 3 1 (Get-Date -Format dd/MM/yyy) # zapisat datum do zosita CurrentScore

    # zistit posledny riadok v stlpci s poctom tahov
$PoslednyRiadokCurSc = ZistitPoslednyRiadok $WorkSheetAktualnaHra 3 2 

$var_RowXLSX.Content = $PoslednyRiadokCurSc # vpisanie cisla posledneho riadku do GUI skrytej pomocnej premennej
$ColumnCurSc = 1  # stlpec v v zosite CurrentScore, do ktoreho sa zacnu vpisovat priebezne hodnoty

    # zistit posledny riadok s datumom v zosite ScoreCumulatives 
$PoslRiadokScCum = ZistitPoslednyRiadok $WorkSheetScoreCumul 3 1

    # skryt tlacitko pre spustenie pocitadla
$var_btnZaciatokHry.Visibility = 'hidden'

    # vitaz predoslej hry
$var_NaTahuJeHrac.Content = 'Víťaz predošlého kola:'
$var_NaTahuJeHrac.Margin = '62,90,0,0'
$var_Hrac.Background = '#FFFAC4FD'    # pozadie pola s menom vitaza z predoslej hry
$var_Hrac.Margin = '310,90,0,0'
$var_Hrac.Content = VitazPredoslejHry # funkcia zisti vitaza predoslej hry

$var_PoradoveCislo.Visibility = 'Hidden'
$var_CisloTahu.Visibility = 'Hidden'

$var_Hrac1_click.content = $false    # pomocna booleanska premeena pre zistenie, kedy sa ma cislo tahu zvysit o 1
$var_Hrac2_click.Content = $false    # vpisanie hodnoty premennej do GUI 
$var_UkoncenieHry.Content = $false   # stav premennej hovori o tom, ci bolo stlacene tlacitko Vyhodnotenie Vysledkov

$var_VitazHry.content = 'Počítadlo skóre pre hru SCRABBLE' 
$var_VitazHry.visibility = 'Visible' 
$var_VitazHry.IsEnabled = $true

$var_Pridat.IsEnabled = $false       # hlavne tlacitko potvrdzujuce pridanie bodov za slovo
$var_Pridat.Content = ''             # text velkeho tlacidla pre pridanie bodov
$var_Pridat.Visibility = 'hidden'

$var_HodnSlova.visibility = 'Hidden' # text box na vkladanie bodov za slovo
$var_KoniecHry.Visibility = 'Hidden' # tlacitko na ukoncenie hry
$var_UkoncitPocitadlo.Visibility = 'Hidden' # hlavne tlacitko na ukoncenie pocitadla

PrehladDoterajsiehoZapolenia
}
 
    # funkcia zisti zo zosita ScoreCumulatives, ktor bol vitazom predoslej hry
Function VitazPredoslejHry{
    $var_PriebeznySucet1.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),2].value
    $var_PriebeznySucet2.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),4].value
    
    if($var_PriebeznySucet1.Content -gt $var_PriebeznySucet2.Content){
        $var_Hrac.Content = $var_Hrac1.Content
    }
    elseif($var_PriebeznySucet2.Content -gt $var_PriebeznySucet1.Content){
        $var_Hrac.Content = $var_Hrac2.Content
    }
    else{
        $var_NaTahuJeHrac.Content = 'Výsledkom predošlej hry bola'
        $var_Hrac.Content = 'remíza'
        $var_Hrac.Margin = '380,88,0,0'
    }
    Return $var_Hrac.Content
}

    # funkcia zisti a porovna pocet vitazstiev pocas doterajsej historie
Function PrehladDoterajsiehoZapolenia {
    # Hrac1 - GUI prehlad doterajsich vitazstiev
$var_lblBodyZaSlovoH1.Content = ''
$var_lblBodySpoluH1.Margin = '223,250,0,0'
$var_lblBodySpoluH1.Content = 'počet víťazstiev'
$var_HodnotaSlova1.Visibility = 'Hidden'
$var_PriebeznySucet1.Margin = '241,276,0,0'
$var_PriebeznySucet1.Content = $WorkSheetScoreCumul[($PoslRiadokScCum + 1),3].value

    # ak je to uplne prva hra novych hhracov
if($var_PriebeznySucet1.Content -eq 0){
    $var_PriebeznySucet1.Content = 0
}
    # ak su to hraci, ktori uz maju zaznamy z predoslych hier
elseif((!$var_PriebeznySucet1.Content)){
    $var_PriebeznySucet1.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),3].value
}

    # Hrac2 - GUI prehlad doterajsich vitazstiev
$var_lblBodyZaSlovoH2.Content = ''
$var_lblBodySpoluH2.Margin = '466,250,0,0'
$var_lblBodySpoluH2.Content = 'počet víťazstiev'
$var_HodnotaSlova2.Visibility = 'Hidden'
$var_PriebeznySucet2.Margin = '484,276,0,0'
$var_PriebeznySucet2.Content = $WorkSheetScoreCumul[($PoslRiadokScCum +1),5].value

if($var_PriebeznySucet2.Content -eq 0){
    $var_PriebeznySucet2.Content = 0
}
elseif((!$var_PriebeznySucet2.Content)){
    $var_PriebeznySucet2.Content = $WorkSheetScoreCumul[($PoslRiadokScCum),5].value
}
       
        # zelene pozadie pre hraca s vyssim poctom vitazstiev
    if($var_PriebeznySucet1.Content -gt $var_PriebeznySucet2.Content){
        $var_PriebeznySucet1.Background = '#00FF00'
    }
    elseif($var_PriebeznySucet1.Content -lt $var_PriebeznySucet2.Content){
        $var_PriebeznySucet2.Background = '#00FF00'
    }    
}

    # zistit v zosite cislo riadku, ktory nasleduje po poslednom pouzitom riadku,
    # aby sa data hry mohli vpisovat do tohto riadku
Function ZistitPoslednyRiadok($WorkSheetZPR,$RowZPR,$ColumnZPR){
    while($WorkSheetZPR[$RowZPR,$ColumnZPR].Value){
        $RowZPR++
    }
    Return ($RowZPR - 1)
}

    # GUI na zaciatku hry po zvoleni zacinajuceho hraca
Function GUIZaciatokHry($var_Hrac){

$var_PoradoveCislo.Visibility = 'Visible'
$var_CisloTahu.Visibility = 'Visible'
$var_StavHry.Content = 'Priebežný stav hry:'    
$var_KoniecHry.Visibility = 'Visible' # tlacitko pre Vyhodnotenie vysledkov
$var_VitazHry.visibility = 'hidden'

$var_Pridat.IsEnabled = $true         # aktivovat tlacitko pre pripocitavanie bodov
$var_Pridat.content = 'Stlač pre pripočítanie bodov za slovo'
$var_Pridat.Visibility = 'visible'

$var_Hrac.Background = '#FFFAC4FD'    # pozadie pola s meno hraca na tahu
$var_Hrac.Margin = '240,72,0,0'
$var_Hrac1.IsEnabled = $false         # deaktivacia tlacitka s menom 1. hraca
$var_Hrac2.IsEnabled = $false         # deaktivacia tlacitka s menom 2. hraca
$var_ZacinajuciHrac.Content = 'Túto hru začal hráč:' + ' ' + $var_Hrac.Content
$var_lblZvolHracov.Content = ''
$var_NaTahuJeHrac.Content = 'Na ťahu je hráč:'
$var_NaTahuJeHrac.Margin = '62,72,0,0'

$var_BodyZaSlovo.Content = 'zadaj body za slovo:'
$var_HodnSlova.visibility = 'Visible'  # zobrazit text box, do ktoreho sa zadavaju body za slovo
$var_UkoncitPocitadlo.Visibility = 'Hidden' # zobrazit tlacitko pre vypnutie pocitadla

    # Hrac1 - prehlad aktualnej hry
$var_lblBodyZaSlovoH1.Content = 'body za slovo'
$var_lblBodyZaSlovoH1.Margin = '189,250,0,0'
$var_lblBodySpoluH1.Content = 'body spolu'
$var_lblBodySpoluH1.Margin = '275,250,0,0'
$var_HodnotaSlova1.Visibility = 'visible'
$var_PriebeznySucet1.Margin = '277,276,0,0'
$var_PriebeznySucet1.Background = '#FFEDCCCC'

    # Hrac2 - prehlad aktualnej hry
$var_lblBodyZaSlovoH2.Content = 'body za slovo'
$var_lblBodyZaSlovoH2.Margin = '431,250,0,0'
$var_lblBodySpoluH2.Margin = '517,250,0,0'
$var_lblBodySpoluH2.Content = 'body spolu'
$var_HodnotaSlova2.Visibility = 'visible'
$var_PriebeznySucet2.Margin = '520,276,0,0'
$var_PriebeznySucet2.Background = '#FFEDCCCC'

#$PoslednyRiadokCurSc = ZistitPoslednyRiadok $WorkSheetAktualnaHra 1 2 # zistit posledny riadok v 2. stlpci (poradove cislo tahu)

    # zobrazit spravne cislo tahu a priebeznych suctov hracov    
    # ak sa hraje nova hra
 #   if($PoslednyRiadokCurSc -eq 2){
        $PoradoveCislo = 1
        $var_PriebeznySucet1.Content = 0
        $var_PriebeznySucet2.Content = 0
 #   }
        # ak sa pokracuje v nedokoncenej predoslej hre - nacitaju sa hodnoty z xlsx
 #   else{ 
 #       $PoradoveCislo = ($WorkSheetAktualnaHra[($PoslednyRiadokCurSc),2].Value + 1)
 #       $var_PriebeznySucet1.Content = $WorkSheetAktualnaHra[($PoslednyRiadokCurSc),4].Value
 #       $var_PriebeznySucet2.Content = $WorkSheetAktualnaHra[($PoslednyRiadokCurSc),6].Value
 #   }
$var_PoradoveCislo.Content = $PoradoveCislo # vpisanie hodnoty do GUI premennej
}

    # funkcia pripocitava body za slovo
function PripocitatBody($var_PriebeznySucet,$var_HodnotaSlova,$PoslednyRiadokCurSc,$var_PoradoveCislo){

    # zobrazit hodnotu slova v GUI
$var_HodnotaSlova.Content = $var_HodnSlova.Text
    
    # obsah premennej zmenit na INTEGER
$PriebeznySucet = [int]::Parse($var_PriebeznySucet.Content)

    # zistit cislo riadku v xlsx
$PoslednyRiadokCurSc = [int]::Parse($var_RowXLSX.content)

    # zapisat do excelu aktualne cislo tahu
$ValueCurSc = $var_PoradoveCislo.Content

DataDoBunky $WorkSheetAktualnaHra ($PoslednyRiadokCurSc + 1) 2 $ValueCurSc

################ priratat hodnotu slova do priebezneho suctu ##############

    # bolo stlacene tlacidlo pre vyhodnotenie vysledkov
if($var_UkoncenieHry.Content -eq $true){ 
    #$PriebeznySucet = $PriebeznySucet - $HodnSlova
    $PomocnePocitadlo = [int]::Parse($var_PomocnePocitadlo.Content)
    $PomocnePocitadlo++
    $var_PomocnePocitadlo.Content = $PomocnePocitadlo
        
        # vyhodnotit pomocne pocitadlo
    if($PomocnePocitadlo -eq 2){
            # deaktivovat tlacidlo na pridavanie bodov
        $var_Pridat.IsEnabled = $false
        #PoVyhodnoteniVysledku
    }
    elseif($PomocnePocitadlo -ne 2){
            # na tahu je hrac1
        if($var_Hrac.Content -eq $var_Hrac1.Content){
            $var_Hrac1_click.Content = $true
        }
            # na tahu je hrac2
        elseif($var_Hrac.Content -eq $var_Hrac2.Content){
            $var_Hrac2_click.Content = $true
        } 
    }
    $PriebeznySucet = $PriebeznySucet - $HodnSlova
}

    # nebolo zatial stlacene tlacidlo pre vyhodnotenie vysledkov
elseif($var_UkoncenieHry.Content -eq $false){
        
        # bola zadana hodnota slova = 0, zobrazi sa vyzva
    if($HodnSlova -eq 0){
        $ZadanaNula = [System.Windows.MessageBox]::Show( "Zadal si nulu. Hráč bude v tomto ťahu stáť?", "Zadaná NULA", "YesNo", "Question" )
        $var_HodnSlova.text = ''
                
            # na tahu je hrac1
            # hrac bude stat
        if($ZadanaNula -eq "Yes" -and $var_Hrac.Content -eq $var_Hrac1.Content){
            $var_Hrac1_click.Content = $true
        }
            # hrac nebude stat
        elseif($ZadanaNula -eq "No" -and $var_Hrac.Content -eq $var_Hrac1.Content){
            $var_Hrac1_click.Content = $false
            $var_Hrac2_click.Content = $false
        }
               
            # na tahu je hrac2
            # hrac bude stat
        if($ZadanaNula -eq "Yes" -and $var_Hrac.Content -eq $var_Hrac2.Content){
            $var_Hrac2_click.Content = $true
        }
            # hrac nebude stat
        elseif($ZadanaNula -eq "No" -and $var_Hrac.Content -eq $var_Hrac2.Content){
            $var_Hrac1_click.Content = $false
            $var_Hrac2_click.Content = $false
        }
    }
            
        # bola zadana hodnota slova > 0
    else{
            # na tahu je hrac1
        if($var_Hrac.Content -eq $var_Hrac1.Content){
            $var_Hrac1_click.Content = $true
        }   
            # na tahu je hrac2
        elseif($var_Hrac.Content -eq $var_Hrac2.Content){
            $var_Hrac2_click.Content = $true
        }
    }
    $PriebeznySucet = $PriebeznySucet + $HodnSlova
}
$var_PriebeznySucet.Content = $PriebeznySucet      # zapisat hodnotu do GUI
        
######################## zapisovanie dat do xlsx #########################
    
    # na tahu je hrac1
if($var_Hrac.content -eq $var_Hrac1.Content){
        # ak bola omylom zadana hodnota slova = 0,
        # hrac1 nestoji ale zada spravnu hodnotu 
    if($ZadanaNula -eq 'No'){
        $var_Hrac.Content = $var_Hrac1.Content
    }
        # zapis do xlsx
    else{
        ZapisDoXLSXPocasHry
        $var_Hrac.Content = $var_Hrac2.Content
    }
}
    # na tahu je hrac2
elseif($var_Hrac.content -eq $var_Hrac2.Content){
        # ak bola omylom zadana hodnota slova = 0,
        # hrac1 nestoji ale zada spravnu hodnotu 
    if($ZadanaNula -eq 'No'){
        $var_Hrac.Content = $var_Hrac2.Content
    }
        # zapis do xlsx
    else{
        ZapisDoXLSXPocasHry
        $var_Hrac.Content = $var_Hrac1.Content
    }
}

################### zistit aktualne poradove cislo hry ##################

$PoradoveCislo = [int]::Parse($var_PoradoveCislo.Content)
        
    # ak bude splnena podmienka pre zvysenie hodnoty tahu
if(($var_Hrac1_click.Content -eq $true) -and ($var_Hrac2_click.Content -eq $true)){
    $PoradoveCislo++ # zvacsit hodnotu cisla hry o 1 a vlozit novu hodnotu do GUI
    $var_PoradoveCislo.Content = $PoradoveCislo
    $PoslednyRiadokCurSc++      # zvacsit hodnotu cisla riadku v exceli o 1 a vlozit novu hodnotu do GUI (hidden)
    $var_RowXLSX.Content = $PoslednyRiadokCurSc
    $var_Hrac1_click.Content = $false
    $var_Hrac2_click.content = $false
}
        
    # pomocne pocitadlo sa spusti po stlaceni zlteho tlacidla pre vyhodnotenie vysledkov
    # ked sa kazdemu hracovi odpocitaju body za nepouzite pismena,
    # pomocne pocitadlo nadobudne hodnotu = 2
if($PomocnePocitadlo -eq 2){
    VyhodnotitVysledky
    GUIPoVyhodnoteniVysledkov # zmenit GUI
}   
}

Function ZapisDoXLSXPocasHry{
    # na zaciatku hry zistit, ktory hrac ide ako prvy a podla toho nastavit
    # cislo stlpca
        
    # na tahu je Hrac1
if($var_Hrac.content -eq $var_Hrac1.Content){
    $ColumnCurSc = 3
    $ValueCurSc = $HodnSlova
        # zapisat hodnotu slova do stlpca v xlsx pre aktualnu hodnotu
    DataDoBunky $WorkSheetAktualnaHra ($PoslednyRiadokCurSc + 1) $ColumnCurSc $ValueCurSc        
    $ColumnCurSc++
        # do dalsieho stlpca sa vlozi hodnota zavisla od toho, ci je to prvy tah v hre alebo dalsi v poradi
        # ak sa jedna o prvy tah, cize cislo riadku = 3
    if($var_RowXLSX.content -eq 2){
        $ValueCurSc = $HodnSlova
    }
    else{ # ak sa jedna o tah dalsi v poradi
        $ValueCurSc = $PriebeznySucet
    }
    DataDoBunky $WorkSheetAktualnaHra ($PoslednyRiadokCurSc + 1) $ColumnCurSc $ValueCurSc
}       
    # na tahu je Hrac2
elseif($var_Hrac.content -eq $var_Hrac2.Content){ 
    $ColumnCurSc = 5
    $ValueCurSc = $HodnSlova
        # zapisat hodnotu slova do stlpca pre aktualnu hodnotu
    DataDoBunky $WorkSheetAktualnaHra ($PoslednyRiadokCurSc + 1) $ColumnCurSc $ValueCurSc
    $ColumnCurSc++

        # ak sa jedna o prvy tah, cize cislo riadku = 3
    if($var_RowXLSX.content -eq 2){
        $ValueCurSc = $HodnSlova
    }
        # ak sa jedna o tah dalsi v poradi
    else{ 
        $ValueCurSc = $PriebeznySucet
    }        
    DataDoBunky $WorkSheetAktualnaHra ($PoslednyRiadokCurSc + 1) $ColumnCurSc $ValueCurSc
}
}

    # vlozit data do bunky zosita 
Function DataDoBunky ($WorkSheetDDB,$RowDDB,$ColumnDDB,$ValueDDB){
    #$WorkSheetDDB[$rowDDB,$ColumnDDB].value = $ValueDDB
    if($WorkSheetDDB -eq $WorkSheetAktualnaHra){
    set-format -address $ExcelPackage.Workbook.Worksheets['CurrentScore'].cells[$rowDDB,$ColumnDDB] -HorizontalAlignment Center
    }
    elseif($WorkSheetDDB -eq $WorkSheetScoreCumul){
        set-format -address $ExcelPackage.Workbook.Worksheets['ScoreCumulatives'].cells[$rowDDB,$ColumnDDB] -HorizontalAlignment Center -BorderAround Thin
    }
    $WorkSheetDDB[$rowDDB,$ColumnDDB].value = $ValueDDB
}
    
    # matematicke vyhodnotenie vysledkov hry
Function VyhodnotitVysledky{

    # prevod textu na INTEGER
$PriebeznySucet1 = [int]::Parse($var_PriebeznySucet1.Content)
$PriebeznySucet2 = [int]::Parse($var_PriebeznySucet2.Content)
        
    # upresnit poziciu napisu s menom vyhercu
$var_Hrac.Margin = "450,12,0,0"
$var_Pridat.Visibility = 'Hidden' # skryt hlavne tlacitko na pridavanie bodov
$var_VitazHry.Visibility = 'visible'
$var_VitazHry.margin = '130,10,0,0'
$var_VitazHry.horizontalAlignment = 'left'
$var_VitazHry.width = '300'

    # zistit posledny riadok s datumom v zosite ScoreCumulatives 
$PoslRiadokScCum = (ZistitPoslednyRiadok $WorkSheetScoreCumul 3 1) + 1

    # ak v zosite ScoreCumulatives stlpci s datumom zatial nieje ziaden zaznam, znamena to,
    # ze sa jedna o uplne prvu hru
if(!($WorkSheetScoreCumul[3,1].value)){
    $PocetVitazstievHrac1 = $WorkSheetScoreCumul[3,3].value
    $PocetVitazstievHrac2 = $WorkSheetScoreCumul[3,5].value
    $PocetHier = $WorkSheetScoreCumul[3,6].value
}
else{
    $PocetVitazstievHrac1 = $WorkSheetScoreCumul[($PoslRiadokScCum - 1),3].value
    $PocetVitazstievHrac2 = $WorkSheetScoreCumul[($PoslRiadokScCum - 1),5].value
    $PocetHier = $WorkSheetScoreCumul[($PoslRiadokScCum -1),6].value
}

    # porovnanie priebeznych suctov
if($PriebeznySucet1 -gt $PriebeznySucet2){
    $var_PriebeznySucet1.Background = '#00FF00'      # zelene pozadie
    $var_VitazHry.Content = 'Víťazom tejto hry je:'
    $var_Hrac.Content = $var_Hrac1.Content
    $PocetVitazstievHrac1 = $PocetVitazstievHrac1 + 1
}
elseif($PriebeznySucet1 -lt $PriebeznySucet2){
    $var_PriebeznySucet2.Background = '#00FF00'      # zelene pozadie
    $var_VitazHry.Content = 'Víťazom tejto hry je:'
    $var_Hrac.Content = $var_Hrac2.Content
    $PocetVitazstievHrac2 = $PocetVitazstievHrac2 + 1
}
else{
    $var_VitazHry.Content = 'Výsledkom tejto hry je:'
    $var_Hrac.Content = 'REMÍZA'
}
$var_HodnotaSlova1.Content = $PocetVitazstievHrac1
$var_HodnotaSlova2.Content = $PocetVitazstievHrac2

    # porovnanie celkoveho poctu vitazstiev
if($PocetVitazstievHrac1 -gt $PocetVitazstievHrac2){
    $var_HodnotaSlova1.Background = '#00FF00'          # zelene pozadie
}
elseif($PocetVitazstievHrac2 -gt $PocetVitazstievHrac1){
    $var_HodnotaSlova2.Background = '#00FF00'
}
elseif($PocetVitazstievHrac1 -eq $PocetVitazstievHrac2){
    $var_HodnotaSlova2.Background = '#FFEDCCCC'
}

    # zapisat vysledky do zosita ScoreCumulatives
$ColumnCum = 1    # stlpec v zosite ScoreCumulatives, do ktoreho sa zacnu vpisovat vysledky hry
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum (Get-Date -Format dd/MM/yyy) # datum
$ColumnCum++
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum $var_PriebeznySucet1.Content # body za hru 1. hraca
$ColumnCum++
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum $PocetVitazstievHrac1        # Pocet vitazstiev 1. hraca
$ColumnCum++
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum $var_PriebeznySucet2.Content # body za hru 2. hraca
$ColumnCum++
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum $PocetVitazstievHrac2        # Pocet vitazstiev 1. hraca
$ColumnCum++
DataDoBunky $WorkSheetScoreCumul $PoslRiadokScCum $ColumnCum ($PocetHier + 1)             # celkovy pocet hier
}

    # GUI na konci hry
Function GUIPoVyhodnoteniVysledkov{
$var_NaTahuJeHrac.Content = ''
$var_BodyZaSlovo.Content = ''
$var_KoniecHry.visibility = 'Hidden'
$var_UkoncitPocitadlo.visibility = 'visible'
$var_HodnSlova.visibility = 'Hidden' # text box na vkladanie bodov za slovo
$var_CisloTahu.Visibility = 'Hidden'
$var_PoradoveCislo.Visibility = 'Hidden'
$var_ZacinajuciHrac.Content = ''

    # Hrac1 - prehlad aktualnej hry
$var_lblBodyZaSlovoH1.Content = 'počet víťazstiev'
$var_lblBodyZaSlovoH1.Margin = '180,250,0,0'
$var_lblBodySpoluH1.Content = 'body spolu'
$var_lblBodySpoluH1.Margin = '275,250,0,0'
$var_HodnotaSlova1.Visibility = 'visible'
$var_PriebeznySucet1.Margin = '277,276,0,0'
    
    # Hrac2 - prehlad aktualnej hry
$var_lblBodyZaSlovoH2.Content = 'počet víťazstiev'
$var_lblBodyZaSlovoH2.Margin = '422,250,0,0'
$var_lblBodySpoluH2.Margin = '517,250,0,0'
$var_lblBodySpoluH2.Content = 'body spolu'
$var_HodnotaSlova2.Visibility = 'visible'
$var_PriebeznySucet2.Margin = '520,276,0,0'
}

    # checkboxy na vyber mena 1. hraca
Function VyberMeno1Hraca{
    $var_chkElzička.Add_Checked({
        $var_Hrac1.Content = $var_chkElzička.Content
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $False
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 2 2 1
    })
    $var_chkElzička.Add_UnChecked({
        $var_Hrac1.Content = ''
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 2 2 0
    })   

    $var_chkTomáš.Add_Checked({
        $var_Hrac1.Content = $var_chkTomáš.Content
        $var_chkElzička.IsEnabled = $false
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 3 2 1
    })
    $var_chkTomáš.Add_UnChecked({
        $var_Hrac1.Content = ''
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 3 2 0
    })

    $var_chkTomik.Add_Checked({
        $var_Hrac1.Content = $var_chkTomik.Content
        $var_chkElzička.IsEnabled = $false
        $var_chkTomáš.IsEnabled = $false
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $False
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 4 2 1
    })
    $var_chkTomik.Add_UnChecked({
        $var_Hrac1.Content = ''
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 4 2 0
    })

    $var_chkZuzanka.Add_Checked({
        $var_Hrac1.Content = $var_chkZuzanka.Content
        $var_chkElzička.IsEnabled = $false
        $var_chkTomáš.IsEnabled = $false
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $False
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 5 2 1
    })
    $var_chkZuzanka.Add_UnChecked({
        $var_Hrac1.Content = ''
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 5 2 0
    }) 

    $var_chkTimko.Add_Checked({
        $var_Hrac1.Content = $var_chkTimko.Content
        $var_chkElzička.IsEnabled = $false
        $var_chkTomáš.IsEnabled = $false
        $var_chkTomik.IsEnabled = $False
        $var_chkZuzanka.IsEnabled = $False
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 6 2 1
    })
    $var_chkTimko.Add_UnChecked({
        $var_Hrac1.Content = ''
        $var_chkElzička.IsEnabled = $true
        $var_chkTomáš.IsEnabled = $true
        $var_chkTomik.IsEnabled = $true
        $var_chkZuzanka.IsEnabled = $true
        $var_chkTimko.IsEnabled = $true
        Write-Host 'H1'$var_Hrac1.Content
        DataDoBunky $WorkSheetHraci 6 2 0
    })
}

    # checkboxy na vyber mena 2. hraca
Function VyberMeno2Hraca{
    $var_chkElzička_copy.Add_Checked({
        $var_Hrac2.Content = $var_chkElzička_copy.Content
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $False
        $var_chkTomik_copy.IsEnabled = $False
        $var_chkZuzanka_copy.IsEnabled = $False
        $var_chkTimko_copy.IsEnabled = $False
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 2 3 1
    })
    $var_chkElzička_copy.Add_UnChecked({
        $var_Hrac2.Content = ''
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 2 3 0
    })   

    $var_chkTomáš_copy.Add_Checked({
        $var_Hrac2.Content = $var_chkTomáš_copy.Content
        $var_chkElzička_copy.IsEnabled = $false
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $False
        $var_chkZuzanka_copy.IsEnabled = $False
        $var_chkTimko_copy.IsEnabled = $False
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 3 3 1
    })
    $var_chkTomáš_copy.Add_UnChecked({
        $var_Hrac2.Content = ''
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 3 3 0
    })

    $var_chkTomik_copy.Add_Checked({
        $var_Hrac2.Content = $var_chkTomik_copy.Content
        $var_chkElzička_copy.IsEnabled = $false
        $var_chkTomáš_copy.IsEnabled = $false
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $False
        $var_chkTimko_copy.IsEnabled = $False
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 4 3 1
    })
    $var_chkTomik_copy.Add_UnChecked({
        $var_Hrac2.Content = ''
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 4 3 0
    })

    $var_chkZuzanka_copy.Add_Checked({
        $var_Hrac2.Content = $var_chkZuzanka_copy.Content
        $var_chkElzička_copy.IsEnabled = $false
        $var_chkTomáš_copy.IsEnabled = $false
        $var_chkTomik_copy.IsEnabled = $False
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $False
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 5 3 1
    })
    $var_chkZuzanka_copy.Add_UnChecked({
        $var_Hrac2.Content = ''
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 5 3 0
    }) 

    $var_chkTimko_copy.Add_Checked({
        $var_Hrac2.Content = $var_chkTimko_copy.Content
        $var_chkElzička_copy.IsEnabled = $false
        $var_chkTomáš_copy.IsEnabled = $false
        $var_chkTomik_copy.IsEnabled = $False
        $var_chkZuzanka_copy.IsEnabled = $False
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 6 3 1
    })
    $var_chkTimko_copy.Add_UnChecked({
        $var_Hrac2.Content = ''
        $var_chkElzička_copy.IsEnabled = $true
        $var_chkTomáš_copy.IsEnabled = $true
        $var_chkTomik_copy.IsEnabled = $true
        $var_chkZuzanka_copy.IsEnabled = $true
        $var_chkTimko_copy.IsEnabled = $true
        Write-Host 'H2'$var_Hrac2.Content
        DataDoBunky $WorkSheetHraci 6 3 0
    })
}


#################### aktivovat excel package ####################
$GameFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter_verzia_s_vyberom_hracov.xlsx"
$ExcelPackage = Open-ExcelPackage $GameFile # open excel package
$WorkSheetAktualnaHra = $ExcelPackage.Workbook.Worksheets['AktualnaHra'].Cells
#$WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets['MamkaTatiKumul'].Cells
$WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets['ZuzkaTatiKumul'].Cells
$WorkSheetHraci = $ExcelPackage.Workbook.Worksheets['Hraci'].Cells

    # GUI po spusteni skriptu, definovanie pociatocnych premennych
#$var_Hrac1.Content = 'Elzička'
$var_Hrac1.Content = 'Zuzanka'
$var_Hrac2.Content = 'Tomáš'
GUIpoSpusteniSkriptu


    # deaktivovat checkboxy na vyber mien hracov
$var_chkElzička.visibility = 'Hidden'
$var_chkTomáš.visibility = 'Hidden'
$var_chkTomik.visibility = 'Hidden'
$var_chkZuzanka.visibility = 'Hidden'
$var_chkTimko.visibility = 'Hidden'

$var_chkElzička_copy.visibility = 'Hidden'
$var_chkTomáš_copy.visibility = 'Hidden'
$var_chkTomik_copy.visibility = 'Hidden'
$var_chkZuzanka_copy.visibility = 'Hidden'
$var_chkTimko_copy.visibility = 'Hidden'
    
<###################### ZACIATOK HRY ########################
 Stlacenim tlacitka s menom niektoreho hraca treba rozhodnut, 
 kto hru zacina - zaroven sa zvyrazni meno zacinajuceho hraca
#############################################################>

$var_Hrac1.Add_Click({    
    $var_Hrac.Content = $var_Hrac1.Content
#    if(($WorkSheetHraci[2,2].value -eq 1) -and ($WorkSheetHraci[4,3].value -eq 1)){
#        $GameFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter_verzia_s_vyberom_hracov.xlsx"
#        $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets['MamkaTatiKumul'].Cells
#    }
    GUIZaciatokHry $var_Hrac # zavolat funkciu na zmenu GUI
})
$var_Hrac2.Add_Click({
    $var_Hrac.Content = $var_Hrac2.Content
#    if(($WorkSheetHraci[2,2].value -eq 1) -and ($WorkSheetHraci[4,3].value -eq 1)){
#        $GameFile = "C:\Users\th3882\OneDrive - AT&T Services, Inc\Documents\Programing\PowerShellTraining\Skripty\GUI\VisualStudio\4 - Game Counter\GameScoreCounter_verzia_s_vyberom_hracov.xlsx"
#        $WorkSheetScoreCumul = $ExcelPackage.Workbook.Worksheets['MamkaTatiKumul'].Cells
#    }
    GUIZaciatokHry $var_Hrac # zavolat funkciu na zmenu GUI
})

#####################################################################
# co sa udeje pri stlaceni tlacitka pre pripocitavanie bodov za slovo
#####################################################################
    
$var_Pridat.Add_Click({

        # z retazca zadaneho ako hodnota slova sa odstrania pripadne prazdne znaky
    $HodnSlova = $var_HodnSlova.text.Trim()
        
        # ak nebola zadana ziadna hodnota slova, zobrazi sa vyzva
    if($var_HodnSlova.Text -eq ''){
        [void] [System.Windows.MessageBox]::Show( "Zadaj body za slovo", "Nezadaná hodnota slova", "OK", "Information" )
        $var_HodnSlova.text = '' # vyprazdnit text box pre vstup hodnoty slova
    }    
        # ak zadana hodnota slova nieje cislo, zobrazi sa vyzva
    elseif(($HodnSlova -match "^\d+$") -eq $false){ 
        [void] [System.Windows.MessageBox]::Show( "Nezadal si číslo. Zadaj celočíselnú hodnotu", "Nezadaná číselná hodnota slova", "OK", "Information" )
        $var_HodnSlova.text = '' # vyprazdnit text box pre vstup hodnoty slova
    }
        # ak bola zadana hodnota slova >= 0, pridat hodnotu slova do priebezneho suctu
    else{   
            # ak je na rade Hrac1, zavolat funkciu na pripocitanie bodov za slovo
        if($var_Hrac.Content -eq $var_Hrac1.Content){
            PripocitatBody $var_PriebeznySucet1 $var_HodnotaSlova1 ($PoslednyRiadokCurSc + 1) $var_PoradoveCislo
        }
            # ak je na rade Hrac2, zavolat funkciu na pripocitanie bodov za slovo
        else{
            PripocitatBody $var_PriebeznySucet2 $var_HodnotaSlova2 ($PoslednyRiadokCurSc + 1) $var_PoradoveCislo
        }   
    }
        # vyprazdnit text box pre vstup hodnoty slova
    $var_HodnSlova.text = ''
})

#################################################################
# Po stlaceni tlacitka pre vyhodnotenie vysledkov, zobrazit vyzvu
#################################################################

$var_KoniecHry.Add_Click({
        # resetovat pocitadla klikov
    $var_Hrac1_click.Content = $false
    $var_Hrac2_click.content = $false

    $var_UkoncenieHry.Content = $true # zmenit stav pomocnej premennej
    $VyslStlacUkoncHry = [System.Windows.MessageBox]::Show("Naozaj chceš ukončiť toto kolo a vyhodnotiť výsledky? Ak áno, zadaj, koľko bodov sa má každému hráčovi odpočítať.", " Ukončenie tohto kola", "YesNo", "Question" )
        
        # ak je odpoved ano, cize hra skoncila, nasleduje odpocitanie bodov za nepouzite slova
    if($VyslStlacUkoncHry -eq 'Yes'){
            # aktualizovat obsah GUI
        $var_NaTahuJeHrac.Content = 'Hráčovi'
        $var_BodyZaSlovo.Content = 'odpočítať body:'
        $var_Pridat.Content = 'Stlač pre odpočítanie bodov za nepoužité slová'
        $var_StavHry.Content = 'Bodový stav na konci hry:'
        $var_KoniecHry.Visibility = 'Hidden'
    }
    else{
        $var_UkoncenieHry.Content = $false # zmenit stav pomocnej premennej
    }
})

<#############################################################
# Pri stlaceni tlacitka pre Ukoncenie pocitadla zobrazit vyzvu
##############################################################>

$var_UkoncitPocitadlo.Add_Click({
    $VyslStlacUkPoc = [System.Windows.MessageBox]::Show( "Chces ukončiť počítadlo?", "Vypnutie počítadla", "YesNo", "Question" )
    if ($VyslStlacUkPoc -eq "Yes"){
        $PoslRiadokCurSc = ZistitPoslednyRiadok $WorkSheetAktualnaHra 3 2
            # vyprazdnit zaznam hry zo zosita CurrentScore
        For($r = 3; $r -le $PoslRiadokCurSc; $r++){
            for($s = 1; $s -le 6;$s++){
            $WorkSheetAktualnaHra[$r,$s].Value = ''
            }
        }
        $psform.Close() # zavriet GUI
    }
})

####################### zobrazit GUI #########################
$psform.ShowDialog()

########### zavriet Excel package a zobrazit excel ###########
Close-ExcelPackage $ExcelPackage #-Show