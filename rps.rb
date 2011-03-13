#!/usr/bin/ruby -w

# ściągawka:
# - porównywanie dat: 
#   wpis['startWorkTime'] < DateTime.strptime('2009-10-14_12:12', '%Y-%m-%d_%H:%M')

require 'date'

wysokoscDiety = 23
$rok = 2010

wpisy = Array.new

File.open("data/rok_#{$rok}.txt", "r") do |infile|

  #line = infile.gets
  while (line = infile.gets)

    wpis = Hash.new

    wpis['startWorkTime'] = DateTime.strptime(infile.gets, '%Y-%m-%d_%H:%M')
    wpis['endWorkTime'] = DateTime.strptime(infile.gets, '%Y-%m-%d_%H:%M')
    wpis['srodekTransportu'] = infile.gets.chop!
    wpis['miejsce'] = "Warszawy"
    wpis['cel'] = "praca nad projektem HydraStor dla 9LivesData sp. z o.o. sp. kom."

    if wpis['srodekTransportu'] == "-"
      wpis['kosztyPodrozy'] = 0.0
      wpis['srodekTransportu'] = "kolej"
      wpis['iloscZalacznikow'] = 0
    elsif wpis['srodekTransportu'] == "--"
      wpis['plik_z_DW'] = infile.gets.chop!
      wpis['miejsce'] = infile.gets.chop!
      wpis['cel'] =  infile.gets.chop!
      wpis['srodekTransportu'] == infile.gets.chop!
    else
      wpis['kosztyPodrozy'] = infile.gets.to_f
      wpis['iloscZalacznikow'] = infile.gets.to_i
    end

    wpisy << wpis

    puts "WPIS: #{wpis['startWorkTime']} - #{wpis['endWorkTime']}"
    #, #{srodekTransportu}, #{iloscZalacznikow}, #{kosztyPodrozy}"
  end
end

# --------------------------------------------------------------------------------------------------

def napiszSlownieLiczbe(lb)
  if lb == 0
    return "zero "
  elsif lb == 100
    return "sto "
  elsif lb > 199
    throw "200 nie obsługiwane"
  elsif lb > 100
    return "sto " + napiszSlownieLiczbe(lb-100)
  elsif lb == 11
    return "jedenaście "
  elsif lb == 12
    return "dwanaście "
  elsif lb == 13
    return "trzynaście "
  elsif lb == 14
    return "czternaście "
  elsif lb == 15
    return "piętnaście "
  elsif lb == 16
    return "szesnaście "
  elsif lb == 17
    return "siedemnaście "
  elsif lb == 18
    return "osiemnaście "
  elsif lb == 19
    return "dziewiętnaście "
  else
    
    dziesiatek = lb.div(10)
    jedynek = lb.modulo(10)

    retval = ""
    
    if dziesiatek == 1
      retval = "dziesięć "
    elsif dziesiatek == 2
      retval = "dwadzieścia "
    elsif dziesiatek == 3
      retval = "trzydzieści "
    elsif dziesiatek == 4
      retval = "czterdzieści "
    elsif dziesiatek == 5
      retval = "pięćdziesiąt "
    elsif dziesiatek == 6
      retval = "sześćdziesiąt "
    elsif dziesiatek == 7
      retval = "siedemdziesiąt "
    elsif dziesiatek == 8
      retval = "osiemdziesiąt "
    elsif dziesiatek == 9
      retval = "dziewięćdziesiąt "
    end
      
    if jedynek == 1
      retval = retval + "jeden "
    elsif jedynek == 2
      retval = retval + "dwa "
    elsif jedynek == 3
      retval = retval + "trzy "
    elsif jedynek == 4
      retval = retval + "cztery "
    elsif jedynek == 5
      retval = retval + "pięć "
    elsif jedynek == 6
      retval = retval + "sześć "
    elsif jedynek == 7
      retval = retval + "siedem "
    elsif jedynek == 8
      retval = retval + "osiem "
    elsif jedynek == 9
      retval = retval + "dziewięć "
    end
      
    return retval
  end
end

def napiszSlownie(koszt)
  zloty = koszt.to_int
  groszy = (koszt.modulo(1)*100).round

  return napiszSlownieLiczbe(zloty) + "zł " + napiszSlownieLiczbe(groszy) + "gr"
end

def piszLiczbe(koszt)
  zloty = koszt.to_int
  groszy = (koszt.modulo(1)*100).round
  if groszy == 0
    return zloty.to_s + " zł "
  else
    return zloty.to_s + " zł " + (groszy<10 ? "0" : "") + groszy.to_s + " gr"
  end
end

# --------------------------------------------------------------------------------------------------

podroze = Array.new
biezacyMiesiac = 4
nrDW = 8

wpisy.each do |wpis|

  podroz = Hash.new

  podroz['poczatek'] = wpis['startWorkTime']
  podroz['koniec'] = wpis['endWorkTime']

  podroz['data'] = (Date.new(wpis['endWorkTime'].year(), wpis['endWorkTime'].month(), wpis['endWorkTime'].mday())+1)

  if podroz['data'].month() != biezacyMiesiac
    biezacyMiesiac = podroz['data'].month()
    nrDW = 1
  else
    nrDW += 1
  end

  podroz['numer'] = "DW #{nrDW}/#{biezacyMiesiac}/#{podroz['data'].year()}"

  czasTrwania = podroz['koniec'] - podroz['poczatek']
  
  minut = (czasTrwania.to_f*24*60).to_i
  godzin = (minut / 60).to_i
  minut %= 60
  dni = (godzin / 24).to_i
  godzin %= 24

  #dieta = dni*wysokoscDiety

  podroz['iloscDiet'] = dni.to_f

  if dni == 0
    if godzin >= 12
      podroz['iloscDiet'] += 1
    elsif godzin >= 8
      podroz['iloscDiet'] += 0.5
    end
  else
    if godzin < 8
      podroz['iloscDiet'] += 0.5
    else
      podroz['iloscDiet'] += 1
    end
  end

  podroz['czas'] = [dni, godzin, minut]
  podroz['miejsce'] = wpis['miejsce']
  podroz['cel'] = wpis['cel']

  if wpis.has_key?("plik_z_DW")
    podroz['plik_z_DW'] = wpis['plik_z_DW']
  else
    podroz['kosztyPrzejazdow'] = wpis['kosztyPodrozy']
    podroz['transport'] = wpis['srodekTransportu']
    podroz['iloscZalacznikow'] = wpis['iloscZalacznikow']
    podroz['koszt'] = podroz['kosztyPrzejazdow'] + podroz['iloscDiet']*wysokoscDiety
  end
  puts "od: #{podroz['poczatek']} do: #{podroz['koniec']}, czas: #{(czasTrwania.to_f*24).to_i} = #{dni} dni #{godzin} h #{minut} min, iloscDiet: #{podroz['iloscDiet']}, ksiegowane: #{podroz['data']}, nr: #{podroz['numer']}"
  
  podroze << podroz

end

# --------------------------------------------------------------------------------------------------

File.open("rok_#{$rok}.tex", "w") do |texfile|

  
  texfile << '\documentclass[12pt,a4paper,twoside]{letter}' << "\n"
  texfile << '\RequirePackage[T1]{fontenc}' << "\n"
  texfile << '\RequirePackage{times}' << "\n"
  texfile << '\RequirePackage[utf8]{inputenc}' << "\n"
#  texfile << '\usepackage{polski}' << "\n"
#  texfile << '\usepackage[utf8]{inputenc}' << "\n"
  texfile << '\RequirePackage[polish]{babel}' << "\n"
#  texfile << '\RequirePackage{comment}' << "\n"
#  texfile << '\RequirePackage{a4wide}' << "\n"
#  texfile << '\RequirePackage{longtable}' << "\n"
#  texfile << '\RequirePackage{multicol}' << "\n"
#  texfile << '\RequirePackage{url}' << "\n"
  texfile << '\begin{document}' << "\n"

  podroze.each do |p|

    puts "numer: #{p['numer']}, data: #{p['data']}, koszt: #{p['koszt']}"
    
    #system("./run.sh \"#{p['numer']}\" \"#{p['data']}\" \"#{p['poczatek']}\" \"#{p['poczatek']}\" \"#{p['koniec']}\" \"#{p['koniec']}\" #{p['czas'][0]} #{p['czas'][1]} #{p['czas'][2]} \"#{p['iloscDiet']}\" kolej \"#{p['kosztyPrzejazdow']}\" \"#{p['iloscZalacznikow']}\"")


    texfile << '\pagestyle{empty}' << "\n"

    texfile << "\\textbf{Dowód Wewnętrzny nr #{p['numer']}}\n"
    texfile << "\\vspace{30px}\n"

texfile << "\\begin{description}\n"
texfile << "\\item[pozycja księgowania:] ..............\n"
texfile << "\\item[data:] #{p['data']}\n"
texfile << "\\end{description}\n"
texfile << "\\vspace{20px}\n"

texfile << "\\begin{description}\n"
texfile << "\\item[Podróż służbową odbył:] Łukasz Ślusarczyk (właściciel)\n"
texfile << "\\item[do:] #{p['miejsce']}\n"
texfile << "\\item[w celu:] #{p['cel']}\n"
texfile << "\\item[wyjazd:] #{p['poczatek'].strftime('%Y-%m-%d %H:%M')}\n"
texfile << "\\item[powrót:] #{p['koniec'].strftime('%Y-%m-%d %H:%M')}\n"
    dniDzienStr = "dni"
    if p['czas'][0] == 1
      dniDzienStr = "dzień"
    end
texfile << "\\item[czas przebywania w podróży:]  #{p['czas'][0]} #{dniDzienStr} #{p['czas'][1]} godzin #{p['czas'][2]} minut\n"
texfile << "\\item[środek transportu:] #{p['transport']}\n"
texfile << "\\end{description}\n"
texfile << "\\vspace{20px}\n"
texfile << "\\begin{description}\n"

if p.has_key?('plik_z_DW')
  File.open(p['plik_z_DW'], "r") do |dwFile|
    texfile << "% wklejenie pliku: #{p['plik_z_DW']} START";
    puts "wklejanie pliku #{p['plik_z_DW']}"
    while (dwLine = dwFile.gets)
      #puts "wczytano #{dwLine}"
      texfile << dwLine
    end
    texfile << "% wklejenie pliku: #{p['plik_z_DW']} KONIEC";    
  end
else
  texfile << "\\item[koszty przejazdów nie zaksięgowane w KPiR (wg załączników):] #{piszLiczbe(p['kosztyPrzejazdow'])}\n"
  texfile << "\\item[liczba przysługujących diet:] #{p['iloscDiet']}\n"
  texfile << "\\item[wysokość diety za dobę podróży:] #{wysokoscDiety} zł\n"
  texfile << "\\item[koszt diet:] #{piszLiczbe(p['iloscDiet']*wysokoscDiety)}\n"
  texfile << "\\item[RAZEM do zaksięgowania w KPiR:]  #{piszLiczbe(p['koszt'])}\n"
  texfile << "\\item[słownie:] " << napiszSlownie(p['koszt']) << "\n"
end

texfile << "\\end{description}\n"
texfile << "\\vspace{20px}\n"
texfile << "\\begin{description}\n"
texfile << "\\item[sporządził i zatwierdził:] Łukasz Ślusarczyk\n"
texfile << "\\item[ilość załączników:] #{p['iloscZalacznikow']}\n"
texfile << "\\end{description}\n"

texfile << "\\vspace{80px}\n"
texfile << "\\begin{description}\n"
texfile << "\\item[podpis osoby zatwierdzającej] ....................................................................\n"
texfile << "\\end{description}\n"

    texfile << '\newpage' << "\n"

  end

  texfile << '\end{document}' << "\n"

end



#system("./run.sh \"#{p['numer']}\" \"#{p['data']}\" \"#{p['poczatek']}\" \"#{p['poczatek']}\" \"#{p['koniec']}\" \"#{p['koniec']}\" #{p['czas'][0]} #{p['czas'][1]} #{p['czas'][2]} \"#{p['iloscDiet']}\" kolej \"#{p['kosztyPrzejazdow']}\" \"#{p['iloscZalacznikow']}\"")


system("latex rok_#{$rok}.tex")
system("dvipdf rok_#{$rok}.dvi rok_#{$rok}.pdf")
system("dvips rok_#{$rok}.dvi -f > rok_#{$rok}.ps")
#system("ps2pdf rok_#{$rok}.ps rok_#{$rok}.pdf")
