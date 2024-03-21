----------------------------------------- TRIVIA -------------------------------------------------------------

-- Preview Data Keseluruhan
SELECT * FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
-- WHERE Province IS NOT NULL
ORDER BY DATE;


-- Preview berapa kali tiap Provinsi di-mention/diinput
-- serta menghitung Total New_Cases, New_Deaths, New_Recovered, New_Active_Cases 
-- untuk mengetahui hubungan jumlahnya dengan kolom yang berawalan Total
SELECT 
  IFNULL(Province, "Indonesia") Province,
  COUNT(IFNULL(Province, "Indonesia")) Mention,
  SUM(New_Cases) Total_NewCases,
  SUM(New_Deaths) Total_NewDeaths,
  SUM(New_Recovered) Total_NewRecovered,
  SUM(New_Active_Cases) Total_NewActiveCases
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
GROUP BY Province
ORDER BY Province; 
-- Keterangan: Ternyata data-data yang ada di kolom dengan awalan "Total" adalah KUMULATIF


-- Preview total kasus dan total kematian karena Covid 19
SELECT
  SUM(New_Cases) Total_Cases,
  SUM(New_Deaths) Total_Deaths,
  SUM(New_Recovered) Total_Recovered
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
WHERE Province IS NOT NULL;  
-- Keterangan: Jika TIDAK mengecualikan Location_Level = "Country" atau dalam hal ini 
--             yang berlabel Province = "Indonesia" maka nilainya menjadi 2 kali lipat lebih


-- Melihat data pada suatu Provinsi 
SELECT
  Date,
  New_Cases,
  Total_Cases,
  New_Deaths,
  Total_Deaths,
  New_Recovered,
  Total_Recovered,
  New_Active_Cases,
  Total_Active_Cases,
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
WHERE Province = "Maluku Utara"
ORDER BY Date;
----------------------------------------- TRIVIA -------------------------------------------------------------


-----------------------------------SOAL---------------------------------------

----------------------------------- NOMOR 1 ---------------------------------------
-- Jumlah total kasus Covid-19 aktif yang baru (New_Active_Cases ?) di setiap provinsi 
-- lalu diurutkan berdasarkan jumlah kasus yang paling BESAR
SELECT 
  IFNULL(Province, "Indonesia") Province, 
  Location_Level,
  SUM(New_Active_Cases) Total_NewActiveCases
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina` 
GROUP BY Province, Location_Level
ORDER BY SUM(New_Active_Cases) DESC;





----------------------------------- NOMOR 2 ---------------------------------------
-- Mengambil 2 (dua) location iso code yang memiliki
-- jumlah total kematian karena Covid-19 paling SEDIKIT
WITH sum_death AS
(
  SELECT 
    Location_ISO_Code, 
    IFNULL(Province, "Indonesia") Province, 
    SUM(New_Deaths) Total_Deaths
  FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
  GROUP BY Location_ISO_Code, Province
  ORDER BY Total_Deaths
)
SELECT *,
FROM sum_death
LIMIT 2;
-- Keterangan: karena kolom Total_Deaths bersifat kumulatif jadi 
--             total kematian dihitung dari penjumlahan kolom New_Deaths
--             sehingga nilai Total New_Deaths akan setara dengan kolom Terakhir pada kolom Total_Deaths





----------------------------------- NOMOR 3 ---------------------------------------
-- Data tentang tanggal-tanggal ketika 
-- rate kasus recovered di Indonesia paling TINGGI
-- beserta jumlah ratenya

-- Aggregate untuk kategori Location_Level = Country 
-- dengan kata lain, data dimana Location = "Indonesia" :
SELECT 
   Date,
   Location,
   Case_Recovered_Rate
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
GROUP BY Date, Location, Case_Recovered_Rate
HAVING Location = "Indonesia" 
ORDER BY Case_Recovered_Rate DESC;

-- Aggregate untuk kategori Location_Level = Province :
SELECT 
   Date,
   CASE 
    WHEN SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)) <= 100
    THEN ROUND(SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)),2)
    ELSE 100.99
   END AS Percent_Recovered
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
GROUP BY Date, Location_Level
HAVING Location_Level = "Province" AND Percent_Recovered <= 100.0
ORDER BY Percent_Recovered DESC;

-- Mencakup Aggregate kategori Location_Level = Country & Province :
SELECT 
   Date,
   CASE 
    WHEN SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)) <= 100
    THEN ROUND(SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)),2)
    ELSE 100.99
   END AS Percent_Recovered
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
GROUP BY Date
HAVING Percent_Recovered <= 100.0
ORDER BY Percent_Recovered DESC;
-- Keterangan: Beberapa data pada tanggal tertentu memiliki jumlah recovered > jumlah kasusnya
--             (mungkin karena faktor delay saat input di data source)
--             sehingga saat diaggregate untuk mencari rate beberapa data nilainya akan melebihi 100.0 atau 100%




----------------------------------- NOMOR 4 ---------------------------------------
-- Total case fatality rate dan case recovered rate dari
-- masing-masing location iso code yang diurutkan dari
-- data yang paling RENDAH

-- Query untuk fatality rate:
WITH Deaths AS
(
  SELECT 
   Location_ISO_Code,
   IFNULL(Province, "Indonesia") Province,
   SUM(New_Deaths) Total_NewDeaths,
   SUM(New_Cases) Total_NewCases,
   CASE 
    WHEN SAFE_DIVIDE(SUM(New_Deaths) * 100.0, SUM(New_Cases)) <= 100
    THEN ROUND(SAFE_DIVIDE(SUM(New_Deaths) * 100.0, SUM(New_Cases)),2)
    ELSE 100.0
   END AS Percent_Fatality
  FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
  GROUP BY Location_ISO_Code, Province
  ORDER BY Percent_Fatality
)
SELECT
  Location_ISO_Code,
  Province, 
  Percent_Fatality
FROM Deaths;

-- Query untuk recovery rate:
WITH Recovery AS
(
  SELECT 
   Location_ISO_Code,
   IFNULL(Province, "Indonesia") Province,
   SUM(New_Recovered) Total_NewRecovered,
   SUM(New_Cases) Total_NewCases,
   CASE
    WHEN SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)) <= 100
    THEN ROUND(SAFE_DIVIDE(SUM(New_Recovered) * 100.0, SUM(New_Cases)),2)
    ELSE 100.0
   END AS Percent_Recovery
  FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`
  GROUP BY Location_ISO_Code, Province
  ORDER BY Percent_Recovery
)
SELECT
  Location_ISO_Code,
  Province, 
  Percent_Recovery
FROM Recovery;
-- Keterangan : fatality rate dan recovery rate dengan query terpisah, tapi 
--              keduanya sama-sama diurutkan dari yang nilainya paling rendah





----------------------------------- NOMOR 5 ---------------------------------------
-- Data tentang tanggal-tanggal saat total kasus
-- Covid-19 mulai menyentuh angka 30.000-an
SELECT 
  Date,
  Total_Cases
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`  
WHERE Total_Cases >= 30000
ORDER BY Date;
-- Keterangan : karena istilah "mulai menyentuh" maka datanya diurutkan berdasarkan tanggal termuda
--               dengan filter >= 30000 pada kolom kumulatif Total_Cases





----------------------------------- NOMOR 6 ---------------------------------------
-- Jumlah data yang tercatat ketika kasus Covid-19 lebih
-- dari atau sama dengan 30.000
SELECT
  COUNT(Date) Total_Data
FROM `datastudio-practicebinar.binar_challenge_1.covid19ina`   
WHERE Total_Cases >= 30000;
-- Keterangan: jumlah datanya sesuai dengan hasil query (Result per page)
--             dari pertanyaan Nomor 5


