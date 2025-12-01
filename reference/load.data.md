# Load data adapted from Mota et al. (2025), Şekercioğlu et al. (2025), Mota et al. (2022), Tobias et al. (2022), and Jetz et al. (2014)

Load data adapted from Mota et al. (2025), Şekercioğlu et al. (2025),
Mota et al. (2022), Tobias et al. (2022), and Jetz et al. (2014)

## Usage

``` r
load.data()
```

## Value

A list with binary maps of species for the reference and future climate
scenarios, species traits, a rooted phylogenetic tree for the species.
The species names across these objects must match! It also includes a
polygon of the CCAF, and the protected areas of the CCAF.

## References

Mota, F. M. M. et al. 2025. Impact of Climate Change on the Multiple
Facets of Forest Bird Diversity in a Biodiversity Hotspot Within the
Atlantic Forest - Diversity and Distributions 31: e70129.

Şekercioğlu, Ç. H. et al. 2025. BIRDBASE: A Global Dataset of Avian
Biogeography, Conservation, Ecology and Life History Traits. -
Scientific Data 12: 1558.

Mota, F. M. M. et al. 2022. Climate change is expected to restructure
forest frugivorous bird communities in a biodiversity hot-point within
the Atlantic Forest. - Diversity and Distributions 28: 2886–2897.

Tobias, J. A. et al. 2022. AVONET: morphological, ecological and
geographical data for all birds. - Ecology Letters 25: 581–597.

Jetz, W. et al. 2014. Global Distribution and Conservation of
Evolutionary Distinctness in Birds. - Current Biology 24: 919–930.

## Examples

``` r
data <- load.data()
data
#> $ref
#> class       : SpatRaster 
#> size        : 67, 25, 68  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : -41.875, -38.75, -21.375, -13  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source      : ref_frugivor.tif 
#> names       : Amazo~inosa, Amazo~rytha, Amazo~nacea, Arrem~uatus, Arrem~urnus, Ptero~lloni, ... 
#> min values  :           0,           0,           0,           0,           1,           0, ... 
#> max values  :           1,           1,           1,           1,           1,           1, ... 
#> 
#> $fut
#> class       : SpatRaster 
#> size        : 67, 25, 68  (nrow, ncol, nlyr)
#> resolution  : 0.125, 0.125  (x, y)
#> extent      : -41.875, -38.75, -21.375, -13  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#> source      : fut_frugivor.tif 
#> names       : Amazo~inosa, Amazo~rytha, Amazo~nacea, Arrem~uatus, Arrem~urnus, Ptero~lloni, ... 
#> min values  :           0,           1,           0,           0,           0,           0, ... 
#> max values  :           1,           1,           1,           1,           1,           1, ... 
#> 
#> $traits
#>                           Beak.Length_Culmen Beak.Length_Nares Beak.Width
#> Amazona_farinosa                        42.3              35.6       20.5
#> Amazona_rhodocorytha                    37.6              29.4       18.0
#> Amazona_vinacea                         33.5              24.6       16.2
#> Arremon_semitorquatus                   15.2               9.4        5.7
#> Arremon_taciturnus                      14.6              10.0        5.5
#> Pteroglossus_bailloni                   70.2              62.2       20.9
#> Cacicus_cela                            33.7              24.0        7.9
#> Carpornis_cucullata                     18.3               9.2        5.6
#> Caryothraustes_canadensis               17.4              11.8        8.5
#> Chiroxiphia_caudata                     13.8               7.3        4.0
#> Chiroxiphia_pareola                     11.4               6.5        4.4
#> Chlorophanes_spiza                      15.9              11.4        4.5
#> Patagioenas_speciosa                    24.5              12.3        4.8
#> Cotinga_maculata                        17.4               9.8        5.9
#> Crax_blumenbachii                       45.7              23.4       15.3
#> Crypturellus_soui                       24.2               8.0        4.2
#> Crypturellus_variegatus                 33.6              13.7        5.3
#> Cyanerpes_cyaneus                       19.4              12.8        3.8
#> Elaenia_mesoleuca                       12.5               7.1        4.1
#> Euphonia_cyanocephala                    9.4               5.4        4.1
#> Euphonia_pectoralis                     10.9               7.6        4.7
#> Euphonia_xanthogaster                   10.7               6.0        4.8
#> Ilicura_militaris                        9.4               5.2        2.8
#> Iodopleura_pipra                         8.2               4.5        3.6
#> Laniisoma_elegans                       20.3              13.2        5.4
#> Legatus_leucophaius                     13.0               8.3        6.3
#> Lipaugus_lanioides                      26.1              16.0        8.0
#> Lipaugus_vociferans                     26.9              13.8        8.0
#> Machaeropterus_regulus                   9.9               5.6        3.3
#> Manacus_manacus                         11.5               6.8        4.4
#> Melanerpes_flavifrons                   27.2              20.9        6.5
#> Mionectes_oleagineus                    11.8               8.2        4.2
#> Mionectes_rufiventris                   14.1               9.3        4.3
#> Neopelma_aurifrons                      12.7               8.3        4.2
#> Odontophorus_capueira                   21.3              11.7        7.6
#> Oxyruncus_cristatus                     17.9              11.3        5.5
#> Pachyramphus_marginatus                 14.7              10.1        6.9
#> Patagioenas_plumbea                     23.1              12.9        4.3
#> Penelope_obscura                        34.5              16.6       10.2
#> Penelope_superciliaris                  34.8              16.3        9.9
#> Phibalura_flavirostris                  13.8               9.5        6.5
#> Phyllomyias_burmeisteri                 11.4               6.9        3.5
#> Pionopsitta_pileata                     25.3              19.0       11.6
#> Pipra_pipra                             12.0               6.6        4.4
#> Pipra_rubrocapilla                      10.4               6.0        3.8
#> Pipraeidea_melanonota                   12.6               7.4        4.8
#> Turdus_flavipes                         21.7              11.0        5.0
#> Procnias_nudicollis                     27.0              10.9        7.1
#> Psarocolius_decumanus                   51.8              34.1       11.2
#> Pteroglossus_aracari                    99.1              93.4       27.7
#> Pyroderus_scutatus                      42.5              26.3       13.8
#> Pyrrhura_cruentata                      22.8              19.1       12.1
#> Ramphastos_dicolorus                   104.3             100.0       30.1
#> Schiffornis_turdina                     17.0               9.7        4.9
#> Schiffornis_virescens                   13.9               8.6        3.8
#> Selenidera_maculirostris                55.0              47.8       19.3
#> Stephanophorus_diadematus               14.1               8.7        6.4
#> Tachyphonus_cristatus                   15.9              11.1        5.6
#> Tangara_cyanocephala                    10.9               8.0        4.0
#> Tangara_cyanoventris                    12.0               7.7        4.0
#> Tangara_desmaresti                      12.6               7.9        4.3
#> Tangara_seledon                         11.8               7.7        5.1
#> Thraupis_cyanoptera                     17.9              10.0        6.4
#> Tinamus_solitarius                      37.9              11.4        5.8
#> Touit_melanonotus                       18.9              14.3        8.8
#> Trogon_viridis                          25.2              15.0       10.1
#> Turdus_fumigatus                        24.2              13.8        5.0
#> Xipholena_atropurpurea                  18.3              10.2        5.2
#>                           Beak.Depth Tarsus.Length Wing.Length Kipps.Distance
#> Amazona_farinosa                35.4          26.6       244.9           68.7
#> Amazona_rhodocorytha            31.0          22.3       210.0           62.6
#> Amazona_vinacea                 26.7          21.5       214.2           67.3
#> Arremon_semitorquatus            7.7          25.2        70.0            4.2
#> Arremon_taciturnus               7.3          23.8        72.0            7.9
#> Pteroglossus_bailloni           26.0          33.0       129.0           18.9
#> Cacicus_cela                    11.8          29.8       145.3           39.5
#> Carpornis_cucullata              6.8          23.3       113.6           22.4
#> Caryothraustes_canadensis       11.2          20.5        90.8           15.8
#> Chiroxiphia_caudata              4.6          19.8        75.9           13.4
#> Chiroxiphia_pareola              4.9          17.8        69.4            8.2
#> Chlorophanes_spiza               4.6          18.9        68.3           16.7
#> Patagioenas_speciosa             6.0          23.7       184.7           65.5
#> Cotinga_maculata                 5.3          22.5       114.2           29.7
#> Crax_blumenbachii               23.3         110.0       384.0           33.9
#> Crypturellus_soui                3.9          36.4       127.5           32.9
#> Crypturellus_variegatus          5.0          41.1       155.4           50.1
#> Cyanerpes_cyaneus                3.6          13.7        60.9           15.7
#> Elaenia_mesoleuca                3.8          16.0        80.0           17.7
#> Euphonia_cyanocephala            4.1          14.5        64.2           18.6
#> Euphonia_pectoralis              5.3          15.9        61.1           13.6
#> Euphonia_xanthogaster            4.8          16.4        61.4           13.7
#> Ilicura_militaris                3.1          17.8        61.2           13.8
#> Iodopleura_pipra                 3.5          13.9        56.6           13.7
#> Laniisoma_elegans                6.1          22.5       103.5           26.9
#> Legatus_leucophaius              4.6          15.1        78.5           20.1
#> Lipaugus_lanioides               8.3          24.6       133.8           22.8
#> Lipaugus_vociferans              7.3          21.4       123.1           20.9
#> Machaeropterus_regulus           3.1          13.9        52.9           12.5
#> Manacus_manacus                  4.2          20.9        52.2            8.4
#> Melanerpes_flavifrons            6.7          18.8       117.0           31.2
#> Mionectes_oleagineus             3.4          16.0        60.5           10.5
#> Mionectes_rufiventris            3.8          16.2        68.4            9.2
#> Neopelma_aurifrons               4.3          15.7        71.0           15.1
#> Odontophorus_capueira           13.1          37.8       146.8           15.2
#> Oxyruncus_cristatus              5.6          20.7        92.2           24.0
#> Pachyramphus_marginatus          5.2          18.5        67.7           15.0
#> Patagioenas_plumbea              5.1          23.1       177.8           61.9
#> Penelope_obscura                12.0          70.6       309.4           14.6
#> Penelope_superciliaris          11.0          71.8       248.6           34.1
#> Phibalura_flavirostris           6.0          19.3        99.0           32.9
#> Phyllomyias_burmeisteri          3.4          15.3        63.9           14.9
#> Pionopsitta_pileata             17.5          14.5       140.0           49.8
#> Pipra_pipra                      4.1          14.1        62.0           10.6
#> Pipra_rubrocapilla               4.1          12.6        61.2           11.5
#> Pipraeidea_melanonota            5.0          17.9        80.1           21.4
#> Turdus_flavipes                  5.7          25.7       110.6           28.6
#> Procnias_nudicollis              5.9          29.4       148.4           35.1
#> Psarocolius_decumanus           17.8          46.5       198.6           49.1
#> Pteroglossus_aracari            32.6          34.5       143.1           22.4
#> Pyroderus_scutatus              15.5          38.0       231.0           41.0
#> Pyrrhura_cruentata              22.7          15.7       147.4           59.5
#> Ramphastos_dicolorus            33.4          46.1       191.8           26.9
#> Schiffornis_turdina              6.0          22.1        92.1           14.1
#> Schiffornis_virescens            4.5          21.4        80.2           12.5
#> Selenidera_maculirostris        22.4          31.8       130.7           19.4
#> Stephanophorus_diadematus        7.5          23.2        98.2           20.4
#> Tachyphonus_cristatus            6.9          18.2        76.2           14.2
#> Tangara_cyanocephala             4.9          16.4        61.5           13.6
#> Tangara_cyanoventris             4.7          18.1        67.0           12.7
#> Tangara_desmaresti               4.7          18.9        71.0           14.2
#> Tangara_seledon                  5.2          15.9        64.2           14.4
#> Thraupis_cyanoptera              7.8          20.8        96.1           24.0
#> Tinamus_solitarius               6.0          73.1       261.5           35.1
#> Touit_melanonotus               13.3          10.2       107.5           45.1
#> Trogon_viridis                  11.7          14.2       146.1           50.6
#> Turdus_fumigatus                 6.7          31.0       113.5           23.9
#> Xipholena_atropurpurea           5.4          20.3       110.2           24.0
#>                           Secondary1 Hand.Wing.Index Tail.Length    Mass
#> Amazona_farinosa               177.2            27.9       135.0  625.99
#> Amazona_rhodocorytha           146.7            29.9       115.0  474.34
#> Amazona_vinacea                145.0            31.6       121.8  254.00
#> Arremon_semitorquatus           65.8             6.1        70.5   25.00
#> Arremon_taciturnus              64.5            10.9        61.3   24.80
#> Pteroglossus_bailloni          110.4            14.5       169.0  146.00
#> Cacicus_cela                   104.1            27.2        97.8   85.45
#> Carpornis_cucullata             90.9            19.8       101.8   74.19
#> Caryothraustes_canadensis       72.5            17.8        71.2   34.50
#> Chiroxiphia_caudata             63.0            17.6        57.8   25.60
#> Chiroxiphia_pareola             59.1            12.2        34.4   16.84
#> Chlorophanes_spiza              50.9            24.7        48.2   19.00
#> Patagioenas_speciosa           114.0            36.5        98.3  258.47
#> Cotinga_maculata                84.5            26.0        71.5   65.00
#> Crax_blumenbachii              307.1             9.7       333.8 3500.00
#> Crypturellus_soui               96.4            25.4        47.9  216.16
#> Crypturellus_variegatus        105.5            32.2        44.6  378.00
#> Cyanerpes_cyaneus               44.5            26.0        34.8   14.00
#> Elaenia_mesoleuca               62.2            22.1        66.4   17.60
#> Euphonia_cyanocephala           45.6            28.9        37.8   14.00
#> Euphonia_pectoralis             48.8            21.8        33.9   14.40
#> Euphonia_xanthogaster           47.7            22.4        36.0   13.00
#> Ilicura_militaris               46.9            22.6        50.8   12.70
#> Iodopleura_pipra                43.0            24.1        32.0   10.03
#> Laniisoma_elegans               76.6            26.0        61.0   47.40
#> Legatus_leucophaius             59.2            25.5        55.2   22.20
#> Lipaugus_lanioides             111.0            17.0       116.0   94.80
#> Lipaugus_vociferans            102.1            16.9       110.2   75.42
#> Machaeropterus_regulus          40.2            23.7        22.6    9.34
#> Manacus_manacus                 44.5            15.9        32.8   16.70
#> Melanerpes_flavifrons           85.8            26.6        69.5   57.78
#> Mionectes_oleagineus            50.8            17.1        48.2   11.17
#> Mionectes_rufiventris           60.0            13.3        55.0   13.30
#> Neopelma_aurifrons              55.9            21.3        50.0   14.00
#> Odontophorus_capueira          130.1            10.5        75.0  425.40
#> Oxyruncus_cristatus             67.2            26.3        64.3   42.00
#> Pachyramphus_marginatus         53.7            21.8        50.4   18.40
#> Patagioenas_plumbea            115.7            34.9       141.6  178.77
#> Penelope_obscura               286.3             4.9       313.5 1770.00
#> Penelope_superciliaris         217.8            13.5       286.8  894.99
#> Phibalura_flavirostris          66.2            33.2       104.8   46.50
#> Phyllomyias_burmeisteri         48.8            23.3        48.1   11.10
#> Pionopsitta_pileata             89.8            35.8        70.2  119.00
#> Pipra_pipra                     51.0            17.3        26.6   11.11
#> Pipra_rubrocapilla              47.0            19.7        31.4   12.00
#> Pipraeidea_melanonota           59.3            26.5        57.8   21.00
#> Turdus_flavipes                 81.9            25.9        84.1   65.14
#> Procnias_nudicollis            111.6            24.0        82.6  172.04
#> Psarocolius_decumanus          146.2            24.8       170.3  206.30
#> Pteroglossus_aracari           120.8            15.6       147.0  250.16
#> Pyroderus_scutatus             183.8            18.2       152.2  357.00
#> Pyrrhura_cruentata              88.5            40.2       130.6   75.90
#> Ramphastos_dicolorus           164.9            14.0       181.2  331.00
#> Schiffornis_turdina             74.5            15.9        67.7   31.70
#> Schiffornis_virescens           67.0            15.7        64.2   25.60
#> Selenidera_maculirostris       111.2            14.8       111.3  164.00
#> Stephanophorus_diadematus       77.4            20.8        81.2   35.40
#> Tachyphonus_cristatus           60.0            19.2        70.4   18.80
#> Tangara_cyanocephala            50.4            21.3        44.7   18.00
#> Tangara_cyanoventris            54.0            19.1        48.4   16.50
#> Tangara_desmaresti              56.8            20.0        52.8   20.40
#> Tangara_seledon                 49.9            22.4        47.5   18.70
#> Thraupis_cyanoptera             72.1            25.0        66.5   43.30
#> Tinamus_solitarius             223.7            13.7       156.2 1386.41
#> Touit_melanonotus               62.4            42.0        41.8   66.51
#> Trogon_viridis                  95.6            34.6       158.4   89.69
#> Turdus_fumigatus                89.6            21.1        90.8   75.70
#> Xipholena_atropurpurea          86.0            21.8        65.1   61.32
#>                             Habitat Trophic.Niche  Range.Size
#> Amazona_farinosa             Forest      Omnivore  6793599.57
#> Amazona_rhodocorytha         Forest     Frugivore     2672.56
#> Amazona_vinacea              Forest      Omnivore   105992.85
#> Arremon_semitorquatus        Forest      Omnivore   215137.21
#> Arremon_taciturnus           Forest      Omnivore  6755484.62
#> Pteroglossus_bailloni        Forest     Frugivore   657171.58
#> Cacicus_cela                 Forest      Omnivore  8569297.31
#> Carpornis_cucullata          Forest     Frugivore   251722.97
#> Caryothraustes_canadensis Shrubland      Omnivore  2650244.99
#> Chiroxiphia_caudata          Forest      Omnivore  1459549.86
#> Chiroxiphia_pareola          Forest     Frugivore  5040298.89
#> Chlorophanes_spiza           Forest     Frugivore  7921066.07
#> Patagioenas_speciosa         Forest     Frugivore  7713359.51
#> Cotinga_maculata             Forest     Frugivore    30327.88
#> Crax_blumenbachii            Forest     Frugivore     1149.72
#> Crypturellus_soui            Forest      Omnivore 11151222.76
#> Crypturellus_variegatus      Forest      Omnivore  5436849.92
#> Cyanerpes_cyaneus            Forest      Omnivore  8340306.15
#> Elaenia_mesoleuca            Forest   Invertivore  2216525.02
#> Euphonia_cyanocephala        Forest     Frugivore  2711347.81
#> Euphonia_pectoralis          Forest     Frugivore  1361244.46
#> Euphonia_xanthogaster        Forest     Frugivore  3715684.50
#> Ilicura_militaris            Forest     Frugivore   840759.23
#> Iodopleura_pipra             Forest     Frugivore   130157.72
#> Laniisoma_elegans            Forest      Omnivore   172527.96
#> Legatus_leucophaius          Forest     Frugivore 11371457.31
#> Lipaugus_lanioides           Forest     Frugivore   201153.30
#> Lipaugus_vociferans          Forest     Frugivore  7063057.92
#> Machaeropterus_regulus       Forest     Frugivore   125343.35
#> Manacus_manacus              Forest     Frugivore  7524946.19
#> Melanerpes_flavifrons        Forest      Omnivore  1557771.44
#> Mionectes_oleagineus         Forest     Frugivore  8947569.12
#> Mionectes_rufiventris        Forest   Invertivore  1057487.40
#> Neopelma_aurifrons           Forest     Frugivore     5071.66
#> Odontophorus_capueira        Forest      Omnivore  1724256.70
#> Oxyruncus_cristatus          Forest     Frugivore  1872045.95
#> Pachyramphus_marginatus      Forest      Omnivore  6344951.42
#> Patagioenas_plumbea          Forest     Frugivore  6564806.47
#> Penelope_obscura             Forest     Frugivore  1012773.03
#> Penelope_superciliaris       Forest     Frugivore  5614395.75
#> Phibalura_flavirostris       Forest     Frugivore  1084489.75
#> Phyllomyias_burmeisteri      Forest   Invertivore   971005.03
#> Pionopsitta_pileata          Forest      Omnivore   728878.23
#> Pipra_pipra                  Forest     Frugivore  4953783.66
#> Pipra_rubrocapilla           Forest     Frugivore  3391760.24
#> Pipraeidea_melanonota        Forest      Omnivore  2111740.74
#> Turdus_flavipes              Forest     Frugivore   940921.44
#> Procnias_nudicollis          Forest     Frugivore  1467436.56
#> Psarocolius_decumanus        Forest      Omnivore 10475235.80
#> Pteroglossus_aracari         Forest     Frugivore  3319977.82
#> Pyroderus_scutatus           Forest     Frugivore  2116677.80
#> Pyrrhura_cruentata           Forest      Omnivore    10274.69
#> Ramphastos_dicolorus         Forest     Frugivore  1394133.06
#> Schiffornis_turdina          Forest      Omnivore  5587673.67
#> Schiffornis_virescens        Forest      Omnivore  1662556.58
#> Selenidera_maculirostris     Forest     Frugivore   930797.49
#> Stephanophorus_diadematus    Forest     Frugivore  1088996.67
#> Tachyphonus_cristatus        Forest      Omnivore  6338485.76
#> Tangara_cyanocephala         Forest     Frugivore   444844.92
#> Tangara_cyanoventris         Forest     Frugivore   475625.93
#> Tangara_desmaresti           Forest     Frugivore   260465.02
#> Tangara_seledon              Forest     Frugivore   672563.84
#> Thraupis_cyanoptera          Forest     Frugivore   224069.57
#> Tinamus_solitarius           Forest      Omnivore  1069608.94
#> Touit_melanonotus            Forest     Frugivore    14296.54
#> Trogon_viridis               Forest     Frugivore  7907953.76
#> Turdus_fumigatus             Forest   Invertivore  4070825.39
#> Xipholena_atropurpurea       Forest     Frugivore     1836.59
#> 
#> $tree
#> 
#> Phylogenetic tree with 68 tips and 67 internal nodes.
#> 
#> Tip labels:
#>   Patagioenas_plumbea, Patagioenas_speciosa, Pyrrhura_cruentata, Pionopsitta_pileata, Amazona_rhodocorytha, Amazona_vinacea, ...
#> 
#> Rooted; includes branch length(s).
#> 
#> $ccaf
#>  class       : SpatVector 
#>  geometry    : polygons 
#>  dimensions  : 1, 9  (geometries, attributes)
#>  extent      : -41.87851, -38.83814, -21.30178, -13.00164  (xmin, xmax, ymin, ymax)
#>  source      : ccaf.gpkg
#>  coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#>  names       : NM_ESTADO NM_REGIAO CD_GEOCUF  GID0           NOME1      area
#>  type        :     <chr>     <chr>     <chr> <chr>           <chr>     <num>
#>  values      :     BAHIA  NORDESTE        29     2 Corredor Ecoló~ 1.179e+07
#>  precmean tempmean elevmean
#>     <num>    <num>    <num>
#>     104.4    22.93    262.8
#> 
#> $pa
#>  class       : SpatVector 
#>  geometry    : polygons 
#>  dimensions  : 283, 33  (geometries, attributes)
#>  extent      : -41.8473, -38.86547, -21.15535, -13.20406  (xmin, xmax, ymin, ymax)
#>  source      : pa_ccaf.gpkg
#>  coord. ref. : lon/lat WGS 84 (EPSG:4326) 
#>  names       : SITE_ID SITE_PID SITE_TYPE        NAME_ENG            NAME
#>  type        :   <int>    <chr>     <chr>           <chr>           <chr>
#>  values      :      47       47        PA Reserva Biológ~ Reserva Biológ~
#>                     48       48        PA Reserva Biológ~ Reserva Biológ~
#>                     51       51        PA Reserva Biológ~ Reserva Biológ~
#>              DESIG       DESIG_ENG DESIG_TYPE IUCN_CAT       INT_CRIT
#>              <chr>           <chr>      <chr>    <chr>          <chr>
#>  Reserva Biológica Biological Res~   National       Ia Not Applicable
#>  Reserva Biológica Biological Res~   National       Ia Not Applicable
#>  Reserva Biológica Biological Res~   National       Ia Not Applicable
#>  (and 23 more)
#>               
#>               
#>               
#>               
#> 
```
