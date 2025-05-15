import re
from datetime import datetime


class Data:
    def __init__(self):
        self.global_data = []

        """
        1 - Male
        2 - Female
        Height - in centimetres
        Age - in yrs
        BP1: BP reading 1
            -> BP1[0] - Systsolic
            -> BP1[1] - Diastolic
        BP2: BP reading 2
            -> BP2[0] - Systsolic
            -> BP2-= [1] - Diastolic

        50th - Normal
        90th - Elevated
        95th - Stage 1 HPTN
        95 + 12mmHg - Stage 2 HPTN
        """
        self.percentile = { 
            1: {
                1:
                {
                    'height': [77.2, 	78.3, 	80.2, 	82.4, 	84.6, 	86.7, 	87.9 ],
                    'Systolic 50th': [85, 	85, 	86, 	86,	87, 	88, 	88],
                    'Systolic 90th': [98, 	99, 	99, 	100, 	100, 	101, 	101 ],
                    'Systolic 95th': [102, 	102, 	103, 	103, 	104, 	105, 	105],
                    'Systolic 95th + 12mmHg': [114, 	114, 	115, 	115, 	116, 	117, 	117 ],
                    'Diastolic 50th': [40, 	40, 	40, 	41, 	41, 	42, 	42],
                    'Diastolic 90th': [52, 	52, 	53, 	53, 	54, 	54, 	54 ],
                    'Diastolic 95th': [54, 	54, 	55, 	55, 	56, 	57, 	57 ],
                    'Diastolic 95th + 12mmHg': [66, 	66, 	67, 	67,	68, 	69, 	69 ],

                },
                2: {
                    'height': [86.1, 	87.4, 	89.6, 	92.1, 	94.7, 	97.1, 	98.5],
                    'Systolic 50th': [87, 	87, 	88, 	89, 	89, 	90, 	91 ],
                    'Systolic 90th': [100, 	100, 	101, 	102, 	103, 	103, 	104 ],
                    'Systolic 95th': [104, 	105, 	105, 	106, 	107, 	107, 	108 ],
                    'Systolic 95th + 12mmHg': [116, 	117, 	117, 	118, 	119, 	119, 	120 ],
                    'Diastolic 50th': [43, 	43, 	44, 	44, 	45, 	46, 	46 ],
                    'Diastolic 90th': [55, 	55, 	56, 	56, 	57, 	58, 	58 ],
                    'Diastolic 95th': [57, 	58, 	58, 	59, 	60, 	61, 	61 ],
                    'Diastolic 95th + 12mmHg': [69, 	70, 	70, 	71, 	72, 	73, 	73 ],

                },
                3: {
                    'height': [92.5, 	93.9, 	96.3, 	99, 	101.8, 	104.3, 	105.8 ],
                    'Systolic 50th': [88, 	89, 	89, 	90, 	91, 	92, 	92 ],
                    'Systolic 90th': [101, 	102, 	102, 	103, 	104, 	105, 	105 ],
                    'Systolic 95th': [106, 	106, 	107,	107, 	108, 	109, 	109 ],
                    'Systolic 95th + 12mmHg': [118, 	118, 	119, 	119, 	120, 	121, 	121 ],
                    'Diastolic 50th': [45, 	46, 	46, 	47, 	48, 	49, 	49 ],
                    'Diastolic 90th': [58, 	58, 	59, 	59, 	60, 	61, 	61],
                    'Diastolic 95th': [60, 	61, 	61, 	62, 	63, 	64, 	64],
                    'Diastolic 95th + 12mmHg': [72, 	73, 	73, 	74, 	75, 	76, 	76],

                },
                4: {
                    'height': [98.5, 	100.2, 	102.9, 	105.9, 	108.9, 	111.5, 	113.2],
                    'Systolic 50th': [90, 	90, 	91, 	92, 	93, 	94, 	94],
                    'Systolic 90th': [102, 	103, 	104, 	105, 	105, 	106, 	107 ],
                    'Systolic 95th': [107, 	107, 	108, 	108, 	109, 	110, 	110 ],
                    'Systolic 95th + 12mmHg': [119, 	119, 	120, 	120, 	121, 	122, 	122 ],
                    'Diastolic 50th': [48, 	49, 	49, 	50, 	51, 	52, 	52 ],
                    'Diastolic 90th': [60, 	61, 	62, 	62, 	63, 	64, 	64 ],
                    'Diastolic 95th': [63, 	64, 	65, 	66, 	67, 	67, 	68 ],
                    'Diastolic 95th + 12mmHg': [75, 	76, 	77, 	78, 	79, 	79, 	80 ],

                },
                5: {
                    'height': [104.4, 	106.2, 	109.1, 	112.4, 	115.7, 	118.6, 	120.3],
                    'Systolic 50th': [91, 	92, 	93, 	94, 	95, 	96, 	96 ],
                    'Systolic 90th': [103, 	104, 	105, 	106, 	107, 	108, 	108 ],
                    'Systolic 95th': [107, 	108, 	109, 	109, 	110, 	111, 	112 ],
                    'Systolic 95th + 12mmHg': [119, 	120, 	121, 	121, 	122, 	123, 	124],
                    'Diastolic 50th': [51, 	51, 	52, 	53, 	54, 	55, 	55],
                    'Diastolic 90th': [63, 	64, 	65, 	65, 	66, 	67, 	67],
                    'Diastolic 95th': [66, 	67, 	68, 	69, 	70, 	70, 	71],
                    'Diastolic 95th + 12mmHg': [78, 	79, 	80, 	81, 	82, 	82, 	83],

                },
                6: {
                    'height': [110.3, 	112.2, 	115.3, 	118.9, 	122.4, 	125.6, 	127.5],
                    'Systolic 50th': [93, 	93, 	94, 	95, 	96, 	97, 	98 ],
                    'Systolic 90th': [105, 	105, 	106, 	107, 	109, 	110, 	110],
                    'Systolic 95th': [108, 	109, 	110, 	111, 	112, 	113, 	114],
                    'Systolic 95th + 12mmHg': [120, 	121, 	122, 	123, 	124, 	125, 	126],
                    'Diastolic 50th': [54, 	54, 	55, 	56, 	57, 	57, 	58],
                    'Diastolic 90th': [66, 	66, 	67, 	68, 	68, 	69, 	69],
                    'Diastolic 95th': [69, 	70, 	70, 	71, 	72, 	72, 	73],
                    'Diastolic 95th + 12mmHg': [81, 	82, 	82, 	83, 	84, 	84, 	85],

                },
                7: {
                    'height': [116.1, 	118, 	121.4, 	125.1, 	128.9, 	132.4, 	134.5],
                    'Systolic 50th': [94, 	94, 	95, 	97, 	98, 	98, 	99],
                    'Systolic 90th': [106, 	107, 	108, 	109, 	110, 	111, 	111],
                    'Systolic 95th': [110, 	110, 	111, 	112, 	114, 	115, 	116],
                    'Systolic 95th + 12mmHg': [122, 	122, 	123, 	124, 	126, 	127, 	128],
                    'Diastolic 50th': [56, 	56, 	57, 	58, 	58, 	59, 	59],
                    'Diastolic 90th': [68, 	68, 	69, 	70, 	70, 	71, 	71],
                    'Diastolic 95th': [71, 	71, 	72, 	73, 	73, 	74, 	74],
                    'Diastolic 95th + 12mmHg': [83, 	83, 	84, 	85, 	85, 	86, 	86],

                },
                8: {
                    'height': [121.4, 	123.5, 	127, 	131, 	135.1, 	138.8, 	141 ],
                    'Systolic 50th': [95, 	96, 	97, 	98, 	99, 	99, 	100],
                    'Systolic 90th': [107, 	108, 	109, 	110, 	111, 	112, 	112],
                    'Systolic 95th': [111, 	112, 	112, 	114, 	115, 	116, 	117],
                    'Systolic 95th + 12mmHg': [123, 	124, 	124, 	126, 	127, 	128, 	129],
                    'Diastolic 50th': [57, 	57, 	58, 	59, 	59, 	60, 	60 ],
                    'Diastolic 90th': [69, 	70, 	70, 	71, 	72, 	72, 	73 ],
                    'Diastolic 95th': [72, 	73, 	73, 	74, 	75, 	75, 	75],
                    'Diastolic 95th + 12mmHg': [84, 	85, 	85, 	86, 	87, 	87, 	87 ],

                },
                9: {
                    'height': [126, 	128.3, 	132.1, 	136.3, 	140.7, 	144.7, 	147.1],
                    'Systolic 50th': [96, 	97, 	98, 	99, 	100, 	101, 	101],
                    'Systolic 90th': [107, 	108, 	109, 	110, 	112, 	113, 	114 ],
                    'Systolic 95th': [112, 	112, 	113, 	115, 	116, 	118, 	119],
                    'Systolic 95th + 12mmHg': [124, 	124, 	125, 	127, 	128, 	130, 	131 ],
                    'Diastolic 50th': [57, 	58, 	59, 	60, 	61, 	62, 	62],
                    'Diastolic 90th': [70, 	71, 	72, 	73, 	74, 	74, 	74 ],
                    'Diastolic 95th': [74, 	74, 	75, 	76, 	76, 	77, 	77 ],
                    'Diastolic 95th + 12mmHg': [86, 	86, 	87, 	88, 	88, 	89, 	89 ],

                },
                10: {
                    'height': [130.2, 	132.7, 	136.7, 	141.3, 	145.9, 	150.1, 	152.7],
                    'Systolic 50th': [97, 	98, 	99, 	100, 	101, 	102, 	103],
                    'Systolic 90th': [108, 	109, 	111, 	112, 	113, 	115, 	116],
                    'Systolic 95th': [112, 	113, 	114,	116, 	118, 	120, 	121],
                    'Systolic 95th + 12mmHg': [124, 	125, 	126, 	128, 	130, 	132, 	133],
                    'Diastolic 50th': [59, 	60, 	61, 	62, 	63, 	63, 	64 ],
                    'Diastolic 90th': [72, 	73, 	74, 	74, 	75, 	75, 	76],
                    'Diastolic 95th': [76, 	76, 	77, 	77, 	78, 	78, 	78],
                    'Diastolic 95th + 12mmHg': [88, 	88, 	89, 	89, 	90, 	90, 	90],

                },
                11: {
                    'height': [134.7, 	137.3, 	141.5, 	146.4, 	151.3, 	155.8, 	158.6 ],
                    'Systolic 50th': [99, 	99, 	101, 	102, 	103, 	104, 	106],
                    'Systolic 90th': [110, 	111, 	112, 	114, 	116, 	117, 	118],
                    'Systolic 95th': [114, 	114, 	116, 	118, 	120, 	123, 	124],
                    'Systolic 95th + 12mmHg': [126, 	126, 	128, 	130, 	132, 	135, 	136],
                    'Diastolic 50th': [61, 	61, 	62, 	63, 	63, 	63, 	63 ],
                    'Diastolic 90th': [74, 	74, 	75, 	75, 	75, 	76, 	76 ],
                    'Diastolic 95th': [77, 	78, 	78, 	78, 	78, 	78, 	78],
                    'Diastolic 95th + 12mmHg': [89, 	90, 	90, 	90, 	90, 	90, 	90],

                },
                12: {
                    'height': [140.3, 	143, 	147.5, 	152.7, 	157.9, 	162.6, 	165.5],
                    'Systolic 50th': [101, 	101, 	102, 	104, 	106, 	108, 	109],
                    'Systolic 90th': [113, 	114, 	115, 	117, 	119, 	121, 	122],
                    'Systolic 95th': [116, 	117, 	118, 	121, 	124, 	126, 	128],
                    'Systolic 95th + 12mmHg': [128, 	129, 	130, 	133, 	136, 	138, 	140],
                    'Diastolic 50th': [61, 	62, 	62, 	62, 	62, 	63, 	63],
                    'Diastolic 90th': [75, 	75, 	75, 	75, 	75, 	76, 	76],
                    'Diastolic 95th': [78, 	78, 	78, 	78, 	78, 	79, 	79],
                    'Diastolic 95th + 12mmHg': [90, 	90, 	90, 	90, 	90, 	91, 	91],

                },
                13: {
                    'height': [147, 	150, 	154.9, 	160.3, 	165.7, 	170.5, 	173.4],
                    'Systolic 50th': [103, 	104, 	105, 	108, 	110, 	111, 	112],
                    'Systolic 90th': [115, 	116, 	118, 	121, 	124, 	126, 	126],
                    'Systolic 95th': [119, 	120, 	122,	125, 	128, 	130,    131],
                    'Systolic 95th + 12mmHg': [131, 	132, 	134, 	137, 	140, 	142, 	143],
                    'Diastolic 50th': [61, 	60, 	61, 	62, 	63, 	64, 	65 ],
                    'Diastolic 90th': [74, 	74, 	74, 	75, 	76, 	77, 	77 ],
                    'Diastolic 95th': [78, 	78, 	78, 	78, 	80, 	81, 	81],
                    'Diastolic 95th + 12mmHg': [90, 	90, 	90, 	90, 	92, 	93, 	93],

                },
                14: {
                    'height': [153.8, 	156.9, 	162, 	167.5, 	172.7, 	177.4, 	180.1],
                    'Systolic 50th': [105, 	106, 	109, 	111, 	112, 	113, 	113],
                    'Systolic 90th': [119, 	120, 	123, 	126, 	127, 	128, 	129],
                    'Systolic 95th': [123, 	125, 	127, 	130, 	132, 	133, 	134],
                    'Systolic 95th + 12mmHg': [135, 	137, 	139, 	142, 	144, 	145, 	146],
                    'Diastolic 50th': [60, 	60, 	62, 	64, 	65, 	66, 	67],
                    'Diastolic 90th': [74, 	74, 	75,	77, 	78, 	79, 	80],
                    'Diastolic 95th': [77, 	78, 	79, 	81, 	82, 	83, 	84],
                    'Diastolic 95th + 12mmHg': [89, 	90, 	91, 	93, 	94, 	95, 	96],

                },
                15: {
                    'height': [159, 	162, 	166.9, 	172.2, 	177.2, 	181.6, 	184.2 ],
                    'Systolic 50th': [108, 	110, 	112, 	113, 	114, 	114, 	114],
                    'Systolic 90th': [123, 	124, 	126, 	128, 	129, 	130, 	130],
                    'Systolic 95th': [127, 	129, 	131, 	132, 	134, 	135, 	135],
                    'Systolic 95th + 12mmHg': [139, 	141, 	143,	144, 	146, 	147, 	147],
                    'Diastolic 50th': [61, 	62, 	64, 	65, 	66, 	67, 	68],
                    'Diastolic 90th': [75, 	76, 	78, 	79, 	80, 	81, 	81 ],
                    'Diastolic 95th': [78, 	79, 	81, 	83, 	84, 	85, 	85],
                    'Diastolic 95th + 12mmHg': [90, 	91, 	93, 	95, 	96, 	97, 	97],

                },
                16: {
                    'height': [162.1, 	165, 	169.6, 	174.6, 	179.5, 	183.8, 	186.4],
                    'Systolic 50th': [111, 	112, 	114, 	115, 	115, 	116, 	116],
                    'Systolic 90th': [126, 	127, 	128, 	129, 	131, 	131, 	132],
                    'Systolic 95th': [130, 	131, 	133, 	134, 	135, 	136, 	137],
                    'Systolic 95th + 12mmHg': [142, 	143, 	145, 	146, 	147, 	148, 	149],
                    'Diastolic 50th': [63, 	64, 	66, 	67, 	68, 	69, 	69],
                    'Diastolic 90th': [77, 	78, 	79, 	80, 	81, 	82, 	82 ],
                    'Diastolic 95th': [80, 	81, 	83, 	84, 	85, 	86, 	86 ],
                    'Diastolic 95th + 12mmHg': [92, 	93, 	95, 	96, 	97, 	98, 	98],

                },
                17: {
                    'height': [163.8, 	166.5, 	170.9, 	175.8, 	180.7, 	184.9, 	187.5 ],
                    'Systolic 50th': [114, 	115, 	116, 	117, 	117, 	118, 	118 ],
                    'Systolic 90th': [128, 	129, 	130, 	131, 	132, 	133, 	134 ],
                    'Systolic 95th': [132, 	133, 	134, 	135, 	137, 	138, 	138],
                    'Systolic 95th + 12mmHg': [144, 	145, 	146, 	147, 	149, 	150, 	150],
                    'Diastolic 50th': [65, 	66, 	67, 	68, 	69, 	70, 	70],
                    'Diastolic 90th': [78, 	79, 	80, 	81, 	82, 	82, 	83],
                    'Diastolic 95th': [81, 	82, 	84, 	85, 	86, 	86, 	87],
                    'Diastolic 95th + 12mmHg': [93, 	94, 	96, 	97, 	98, 	98, 	99],

                }
                
        }, 
        2: {
                1:{
                    'height': [75.4, 	76.6, 	78.6, 	80.8, 	83, 	84.9, 	86.1],
                    'Systolic 50th': [84, 	85, 	86, 	86, 	87, 	88, 	88 ],
                    'Systolic 90th': [98, 	99, 	99, 	100, 	101, 	102,	102 ],
                    'Systolic 95th': [101, 	102, 	102, 	103,	104, 	105, 	105],
                    'Systolic 95th + 12mmHg': [113, 	114, 	114,	115, 	116, 	117, 	117],
                    'Diastolic 50th': [41, 	42, 	42, 	43, 	44, 	45, 	46],
                    'Diastolic 90th': [54, 	55, 	56, 	56, 	57, 	58, 	58],
                    'Diastolic 95th': [59, 	59, 	60, 	60, 	61, 	62, 	62],
                    'Diastolic 95th + 12mmHg': [71, 	71, 	72, 	72,	73, 	74, 	74 ],
                },
                2: {
                    'height': [84.9, 	86.3, 	88.6, 	91.1, 	93.7,	96, 	97.4],
                    'Systolic 50th': [87, 	87, 	88, 	89, 	90, 	91, 	91  ],
                    'Systolic 90th': [101, 	101, 	102, 	103, 	104,	105, 	106],
                    'Systolic 95th': [104, 	105, 	106, 	106, 	107, 	108, 	109 ],
                    'Systolic 95th + 12mmHg': [116, 	117, 	118, 	118, 	119, 	120, 	121 ],
                    'Diastolic 50th': [45, 	46, 	47, 	48, 	49, 	50, 	51],
                    'Diastolic 90th': [58, 	58, 	59, 	60, 	61, 	62, 	62],
                    'Diastolic 95th': [62, 	63, 	63, 	64, 	65, 	66, 	66 ],
                    'Diastolic 95th + 12mmHg': [74, 	75, 	75, 	76, 	77, 	78, 	78],

                },
                3: {
                    'height': [91, 	92.4, 	94.9, 	97.6, 	100.5, 	103.1, 	104.6],
                    'Systolic 50th': [88, 	89, 	89, 	90, 	91, 	92, 	93 ],
                    'Systolic 90th': [102, 	103, 	104, 	104, 	105, 	106, 	107],
                    'Systolic 95th': [106, 	106, 	107, 	108, 	109, 	110, 	110],
                    'Systolic 95th + 12mmHg': [118, 	118, 	119, 	120, 	121, 	122, 	122],
                    'Diastolic 50th': [48, 	48, 	49, 	50, 	51, 	53, 	53],
                    'Diastolic 90th': [60, 	61, 	61, 	62, 	63, 	64, 	65],
                    'Diastolic 95th': [64, 	65, 	65, 	66, 	67, 	68, 	69],
                    'Diastolic 95th + 12mmHg': [76, 	77, 	77, 	78, 	79, 	80, 	81],

                },
                4: {
                    'height': [97.2, 	98.8, 	101.4, 	104.5, 	107.6, 	110.5, 	112.2],
                    'Systolic 50th': [89, 	90, 	91, 	92, 	93, 	94, 	94 ],
                    'Systolic 90th': [103, 	104, 	105, 	106,	107, 	108, 	108 ],
                    'Systolic 95th': [107, 	108, 	109, 	109, 	110, 	111, 	112],
                    'Systolic 95th + 12mmHg': [119, 	120, 	121, 	121, 	122, 	123, 	124],
                    'Diastolic 50th': [50, 	51, 	51, 	53, 	54, 	55, 	55 ],
                    'Diastolic 90th': [62, 	63, 	64, 	65, 	66, 	67, 	67],
                    'Diastolic 95th': [66, 	67, 	68, 	69,	70, 	70, 	71],
                    'Diastolic 95th + 12mmHg': [78, 	79, 	80, 	81, 	82, 	82, 	83 ],

                },
                5: {
                    'height': [103.6, 	105.3, 	108.2, 	111.5, 	114.9, 	118.1, 	120],
                    'Systolic 50th': [90, 	91, 	92, 	93, 	94, 	95, 	96],
                    'Systolic 90th': [104, 	105, 	106, 	107, 	108, 	109, 	110],
                    'Systolic 95th': [108, 	109, 	109, 	110, 	111, 	112, 	113],
                    'Systolic 95th + 12mmHg': [120, 	121, 	121, 	122, 	123, 	124, 	125],
                    'Diastolic 50th': [52, 	52, 	53, 	55, 	56, 	57, 	57],
                    'Diastolic 90th': [64, 	65, 	66, 	67, 	68, 	69, 	70 ],
                    'Diastolic 95th': [68, 	69, 	70, 	71, 	72, 	73, 	73 ],
                    'Diastolic 95th + 12mmHg': [80, 	81, 	82, 	83, 	84, 	85, 	85 ],

                },
                6: {                    
                    'height': [110, 	111.8, 	114.9, 	118.4, 	122.1, 	125.6, 	127.7],
                    'Systolic 50th': [92, 	92, 	93, 	94, 	96, 	97, 	97 ],
                    'Systolic 90th': [105, 	106, 	107, 	108, 	109, 	110, 	111],
                    'Systolic 95th': [109, 	109, 	110, 	111, 	112, 	113, 	114],
                    'Systolic 95th + 12mmHg': [121, 	121, 	122,	123, 	124, 	125, 	126],
                    'Diastolic 50th': [54, 	54, 	55, 	56, 	57, 	58, 	59],
                    'Diastolic 90th': [67, 	67, 	68, 	69, 	70, 	71, 	71],
                    'Diastolic 95th': [70, 	71, 	72, 	72, 	73, 	74, 	74 ],
                    'Diastolic 95th + 12mmHg': [82, 	83, 	84, 	84, 	85, 	86, 	86] ,

                },
                7: {                    
                    'height': [115.9, 	117.8, 	121.1, 	124.9, 	128.8, 	132.5, 	134.7 ],
                    'Systolic 50th': [92, 	93, 	94,	    95, 	97, 	98, 	99],
                    'Systolic 90th': [106, 	106, 	107, 	109, 	110, 	111, 	112],
                    'Systolic 95th': [109 ,	110, 	111, 	112, 	113, 	114, 	115],
                    'Systolic 95th + 12mmHg': [121, 	122, 	123, 	124, 	125, 	126, 	127],
                    'Diastolic 50th': [55, 	55, 	56, 	57, 	58, 	59, 	60],
                    'Diastolic 90th': [68, 	68, 	69, 	70, 	71, 	72, 	72],
                    'Diastolic 95th': [72, 	72, 	73, 	73, 	74, 	74, 	75],
                    'Diastolic 95th + 12mmHg': [84, 	84, 	85, 	85, 	86, 	86, 	87],

                },
                8: {                    
                    'height': [121, 	123, 	126.5, 	130.6, 	134.7, 	138.5, 	140.9],
                    'Systolic 50th': [93, 	94, 	95, 	97, 	98, 	99, 	100 ],
                    'Systolic 90th': [107, 	107, 	108, 	110, 	111, 	112, 	113],
                    'Systolic 95th': [110, 	111, 	112,	113, 	115, 	116, 	117 ],
                    'Systolic 95th + 12mmHg': [122, 	123, 	124, 	125, 	127, 	128, 	129],
                    'Diastolic 50th': [56, 	56, 	57, 	59, 	60, 	61, 	61],
                    'Diastolic 90th': [69, 	70, 	71, 	72, 	72, 	73, 	73 ],
                    'Diastolic 95th': [72, 	73, 	74, 	74, 	75, 	75, 	75 ],
                    'Diastolic 95th + 12mmHg': [84, 	85, 	86, 	86, 	87, 	87, 	87],

                },
                9: {                    
                    'height': [125.3, 	127.6, 	131.3, 	135.6, 	140.1, 	144.1, 	146.6],
                    'Systolic 50th': [95, 	95, 	97, 	98, 	99, 	100, 	101],
                    'Systolic 90th': [108, 	108, 	109, 	111, 	112, 	113, 	114],
                    'Systolic 95th': [112, 	112, 	113, 	114, 	116, 	117, 	118 ],
                    'Systolic 95th + 12mmHg': [124, 	124, 	125, 	126, 	128, 	129, 	130 ],
                    'Diastolic 50th': [57, 	58, 	59, 	60, 	60, 	61, 	61],
                    'Diastolic 90th': [71, 	71, 	72, 	73, 	73, 	73, 	73 ],
                    'Diastolic 95th': [74, 	74, 	75, 	75, 	75, 	75, 	75],
                    'Diastolic 95th + 12mmHg': [86, 	86, 	87, 	87, 	87, 	87, 	87],

                },
                10: {                    
                    'height': [129.7, 	132.2, 	136.3, 	141, 	145.8, 	150.2, 	152.8],
                    'Systolic 50th': [96, 	97, 	98, 	99, 	101, 	102, 	103 ],
                    'Systolic 90th': [109, 	110, 	111, 	112, 	113, 	115,	116 ],
                    'Systolic 95th': [113, 	114, 	114, 	116, 	117, 	119, 	120 ],
                    'Systolic 95th + 12mmHg': [125, 	126, 	126, 	128, 	129, 	131, 	132],
                    'Diastolic 50th': [58, 	59, 	59, 	60, 	61, 	61, 	62],
                    'Diastolic 90th': [72,	73, 	73, 	73, 	73, 	73, 	73 ],
                    'Diastolic 95th': [75, 	75, 	76, 	76, 	76, 	76, 	76],
                    'Diastolic 95th + 12mmHg': [87, 	87, 	88, 	88, 	88, 	88, 	88 ],

                },
                11: {                    
                    'height': [135.6, 	138.3, 	142.8, 	147.8, 	152.8,	157.3, 	160],
                    'Systolic 50th': [98, 	99, 	101, 	102, 	104, 	105, 	106],
                    'Systolic 90th': [111, 	112, 	113, 	114, 	116, 	118, 	120 ],
                    'Systolic 95th': [115, 	116, 	117, 	118, 	120, 	123, 	124 ],
                    'Systolic 95th + 12mmHg': [127, 	128, 	129, 	130, 	132, 	135, 	136],
                    'Diastolic 50th': [60, 	60, 	60, 	61, 	62, 	63, 	64 ],
                    'Diastolic 90th': [74, 	74, 	74, 	74, 	74, 	75, 	75 ],
                    'Diastolic 95th': [76, 	77, 	77, 	77, 	77, 	77, 	77],
                    'Diastolic 95th + 12mmHg': [88, 	89, 	89, 	89, 	89, 	89, 	89],

                },
                12: {                    
                    'height': [142.8, 	145.5, 	149.9, 	154.8, 	159.6, 	163.8, 	166.4 ],
                    'Systolic 50th': [102, 	102, 	104, 	105, 	107, 	108, 	108 ],
                    'Systolic 90th': [114, 	115, 	116, 	118, 	120, 	122, 	122 ],
                    'Systolic 95th': [118, 	119, 	120, 	122, 	124, 	125, 	126 ],
                    'Systolic 95th + 12mmHg': [130, 	131, 	132, 	134, 	136, 	137, 	138],
                    'Diastolic 50th': [61, 	61, 	61, 	62, 	64, 	65, 	65 ],
                    'Diastolic 90th': [75, 	75, 	75, 	75, 	76, 	76, 	76],
                    'Diastolic 95th': [78, 	78, 	78, 	78, 	79, 	79, 	79],
                    'Diastolic 95th + 12mmHg': [90, 	90, 	90, 	90, 	91, 	91, 	91],

                },
                13: {                    
                    'height': [148.1, 	150.6, 	154.7, 	159.2, 	163.7, 	167.8, 	170.2],
                    'Systolic 50th': [104, 	105, 	106, 	107, 	108, 	108, 	109],
                    'Systolic 90th': [116, 	117, 	119, 	121, 	122, 	123, 	123 ],
                    'Systolic 95th': [121, 	122, 	123, 	124, 	126, 	126, 	127 ],
                    'Systolic 95th + 12mmHg': [133, 	134, 	135, 	136, 	138, 	138, 	139],
                    'Diastolic 50th': [62, 	62, 	63, 	64, 	65, 	65, 	66],
                    'Diastolic 90th': [75, 	75, 	75, 	76, 	76,	    76, 	76, ],
                    'Diastolic 95th': [79, 	79, 	79, 	79, 	80, 	80, 	81 ],
                    'Diastolic 95th + 12mmHg': [91, 	91, 	91, 	91, 	92, 	92, 	93],

                },
                14: {                    
                    'height': [150.6, 	153, 	156.9, 	161.3, 	165.7, 	169.7, 	172.1],
                    'Systolic 50th': [105, 	106, 	107, 	108, 	109, 	109, 	109 ],
                    'Systolic 90th': [118, 	118, 	120, 	122, 	123, 	123, 	123],
                    'Systolic 95th': [123, 	123, 	124, 	125, 	126, 	127, 	127 ],
                    'Systolic 95th + 12mmHg': [135, 	135, 	136, 	137, 	138, 	139, 	139],
                    'Diastolic 50th': [63, 	63, 	64, 	65, 	66, 	66, 	66],
                    'Diastolic 90th': [76, 	76, 	76, 	76, 	77, 	77, 	77],
                    'Diastolic 95th': [80, 	80, 	80, 	80, 	81, 	81, 	82],
                    'Diastolic 95th + 12mmHg': [92, 	92, 	92, 	92, 	93, 	93, 	94],

                },
                15: {                    
                    'height': [151.7, 	154, 	157.9, 	162.3, 	166.7, 	170.6, 	173 ],
                    'Systolic 50th': [105, 	106, 	107, 	108, 	109, 	109, 	109],
                    'Systolic 90th': [118, 	119, 	121, 	122, 	123, 	123, 	124],
                    'Systolic 95th': [124, 	124, 	125, 	126, 	127, 	127, 	128 ],
                    'Systolic 95th + 12mmHg': [136, 	136, 	137, 	138, 	139, 	139, 	140],
                    'Diastolic 50th': [64, 	64, 	64, 	65, 	66, 	67, 	67],
                    'Diastolic 90th': [76, 	76, 	76, 	77, 	77, 	78, 	78 ],
                    'Diastolic 95th': [80, 	80, 	80, 	81, 	82, 	82, 	82],
                    'Diastolic 95th + 12mmHg': [92, 	92, 	92, 	93, 	94, 	94, 	94],

                },
                16: {                    
                    'height': [152.1, 	154.5,	158.4, 	162.8, 	167.1, 	171.1, 	173.4],
                    'Systolic 50th': [106, 	107, 	108, 	109, 	109, 	110, 	110],
                    'Systolic 90th': [119, 	120, 	122, 	123, 	124, 	124, 	124],
                    'Systolic 95th': [124, 	125, 	125, 	127, 	127, 	128, 	128],
                    'Systolic 95th + 12mmHg': [136, 	137, 	137, 	139, 	139, 	140, 	140 ],
                    'Diastolic 50th': [64, 	64, 	65, 	66, 	66, 	67, 	67],
                    'Diastolic 90th': [76, 	76, 	76, 	77, 	78, 	78, 	78],
                    'Diastolic 95th': [80, 	80, 	80, 	81, 	82, 	82, 	82],
                    'Diastolic 95th + 12mmHg': [92, 	92, 	92, 	93, 	94, 	94, 	94],

                },
                17: {                    
                    'height': [152.4, 	154.7, 	158.7, 	163.0, 	167.4, 	171.3, 	173.7],
                    'Systolic 50th': [107, 	108, 	109, 	110,	110, 	110, 	111 ],
                    'Systolic 90th': [120, 	121, 	123, 	124, 	124, 	125, 	125],
                    'Systolic 95th': [125, 	125, 	126, 	127, 	128, 	128, 	128 ],
                    'Systolic 95th + 12mmHg': [137, 	137, 	138, 	139, 	140, 	140, 	140],
                    'Diastolic 50th': [64, 	64, 	65, 	66, 	66, 	66, 	67],
                    'Diastolic 90th': [76, 	76, 	77, 	77, 	78, 	78, 	78 ],
                    'Diastolic 95th': [80, 	80, 	80, 	81, 	82, 	82, 	82 ],
                    'Diastolic 95th + 12mmHg': [92, 	92, 	92, 	93, 	94, 	94, 	94],

                }
            }
        }


    def loader(self):
        with open("Composite_sheet_cleaned.csv", "r") as f:
            next(f)
            for line in f:
                self.global_data.append(line.strip().split(','))


class Patient:
    def __init__(self, rec):
        # rec: [IID, sex, height_cm, DOB_dd/mm/YYYY, BP1_str, BP2_str]
        self.record_ID     = rec[0]
        self.sex_at_birth  = 2 if rec[1].lower().startswith("f") else 1
        self.height        = float(rec[2]) if rec[2] else None
        # parse date of birth
        self.DOB           = datetime.strptime(rec[3], "%d/%m/%Y")
        # placeholders
        self.BP1_sys = self.BP1_dia = None
        self.BP1_date = None
        self.BP2_sys = self.BP2_dia = None
        self.BP2_date = None

        def parse_bp(field_str):
            m = re.search(r"(\d+)\s*/\s*(\d+)", field_str)
            d = re.search(r"\(([^)]+)\)", field_str)
            if not m:
                return None, None, None
            sys, dia = int(m.group(1)), int(m.group(2))
            meas_date = None
            if d:
                ds = d.group(1)
                for fmt in ("%d%b-%Y","%d%b%Y"):
                    try:
                        meas_date = datetime.strptime(ds, fmt)
                        break
                    except ValueError:
                        continue
            return sys, dia, meas_date

        # parse BP1 and BP2
        if rec[4] and rec[4].upper() != "N/A":
            self.BP1_sys, self.BP1_dia, self.BP1_date = parse_bp(rec[4])
        if rec[5] and rec[5].upper() != "N/A":
            self.BP2_sys, self.BP2_dia, self.BP2_date = parse_bp(rec[5])

    def classify(self, sys, dia, meas_date, pct):
        age_years = ((meas_date - self.DOB).days / 365.25) if meas_date else ((datetime.today() - self.DOB).days / 365.25)
        age = int(age_years)
        if age not in pct[self.sex_at_birth]:
            return None, None
        heights = pct[self.sex_at_birth][age]['height']
        idx = next((i for i,h in enumerate(heights) if self.height <= h), len(heights)-1)
        S50  = pct[self.sex_at_birth][age]['Systolic 50th'][idx]
        S90  = pct[self.sex_at_birth][age]['Systolic 90th'][idx]
        S95  = pct[self.sex_at_birth][age]['Systolic 95th'][idx]
        D50  = pct[self.sex_at_birth][age]['Diastolic 50th'][idx]
        D90  = pct[self.sex_at_birth][age]['Diastolic 90th'][idx]
        D95  = pct[self.sex_at_birth][age]['Diastolic 95th'][idx]
        # systolic category
        if sys is None or dia is None:
            return None, None
        if   sys <= S50:   sys_cat = "50: Normal"
        elif sys <= S90:   sys_cat = "90: Elevated"
        elif sys <= S95:   sys_cat = "95: Hypertension Stage 1"
        else:              sys_cat = "95 plus 12: Hypertension Stage 2"
        # diastolic category
        if   dia <= D50:   dia_cat = "50: Normal"
        elif dia <= D90:   dia_cat = "90: Elevated"
        elif dia <= D95:   dia_cat = "95: Hypertension Stage 1"
        else:              dia_cat = "95 plus 12: Hypertension Stage 2"
        return sys_cat, dia_cat

    def percentile_calculation(self, pct):
        bp1_cat = self.classify(self.BP1_sys, self.BP1_dia, self.BP1_date, pct)
        bp2_cat = self.classify(self.BP2_sys, self.BP2_dia, self.BP2_date, pct)
        # mirror missing
        if any(v is None for v in bp1_cat) and all(v is not None for v in bp2_cat):
            bp1_cat = bp2_cat
        if any(v is None for v in bp2_cat) and all(v is not None for v in bp1_cat):
            bp2_cat = bp1_cat
        return list(bp1_cat), list(bp2_cat)

if __name__ == "__main__":
    data = Data()
    data.loader()
    patients = [Patient(rec) for rec in data.global_data]
    print(patients[0].percentile_calculation(data.percentile))
