/**
 * Vzorovy konfiguracny pre potreby projektu
 */
config = {
	"database" : {
		"name": "tedi", // meno terminologickej databazy 
		"url_base": "https://deb.fi.muni.cz:8010/tedi",
		"url_base_s": "https://deb.fi.muni.cz:8010/"
	},
	"content" : [
		{
			"type": "checkbox",
			"values": [["prefinal", "predfinalny"], ["final", "finalny"]]
		},
		{
			"type": "select",
			"label": "obor",
			"name": "entry",
			"multiple": true, // true/false
			// zoznam dvojic [hodnota, popisok] ([value, label])
			"values": [["kres", "kresba-grafika"], ["grdes", "graficky design"]]
		},
		{
			"type": "text",
			"label": "heslo",
			"values": [["word_cz", "ceske"], ["word_en", "anglicke"]]
		},
		{
			"type": "text",
			"label": "varianty",
			"values": "var",
			"multiple": true
		}
	]
}
