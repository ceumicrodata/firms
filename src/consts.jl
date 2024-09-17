const balance_input = "input/merleg-LTS-2022/balance/balance_sheet_80_21.dta"
const balance_output = "temp/balance.dta"
const figure_folder = "output/fig"
const ceo_input = "input/ceo-panel/ceo-panel.dta"

# Strategic partnership tax ids from https://chatgpt.com/share/c5dcc714-27ef-45ff-a288-2e76b166e484
const strategic_partnership = [
    10886861,
    10484878,
    10584215,
    14398649,
    10552821,
    13602059,
    14856505,
    10836653,
    14146136,
    10307078,
    12565159,
    21981128,
    13835400,
    12964493,
    23391475,
    12658387,
    10518869,
    10782004,
    14476732,
    13563590,
    10387128,
    10798982,
    12191525,
    13534776,
    10495892,
    11457695,
    10732346,
    10461925,
    11672953,
    10534296,
    10276451,
    12751428,
    11107792,
    11026778,
    10686506,
    10537017,
    11138075,
    26086163,
    10315192,
    12089675,
    10600601,
    10773381,
    10926651,
    10854343,
    11169176,
    10159277,
    10303720,
    12364855,
    14906222,
    22102533,
    11194044,
    11242941,
    10637959,
    10845606,
    11331364,
    11130235,
    11186542,
    13292629,
    11759849,
    12636332,
    13044859,
    13122791,
    10584473,
    11863650,
    28424374,
    13869975,
    13357845,
    23337965,
    26201720,
    12548051,
    13097596,
    25045675,
    14061716,
    12899986,
    11935243,
    12342659,
    10539868,
    13148001,
    23408894,
    23016910,
    26250061,
    10332692,
    10326556,
    25524468,
    13410021,
    11829519,
    13749619,
    12880706,
    27030945,
    10370782,
    12176780,
    10450633,
    10577501,
    25426281,
    12169533,
    11307064,
    25343007,
    27754025
]
