import ProgressMeter
import ..ArrayUtils: vary

InfoUtils.info(::Val{:cine}, file::AbstractString; ka...) = cine_info(fname)

from(::Val{:cine}, file::AbstractString; slice=nothing, prgrs=true) =
begin
    isa(slice, Integer) && (return fromcine(file, slice))
    isa(slice, UnitRagen) && (return fromcine(file, slice; prgrs))
    fromcine(file; prgrs)
end

_LinLUT =
UInt16[2, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,17,18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 167, 168, 169, 170, 171, 172, 173, 175, 176, 177, 178, 179, 181, 182, 183, 184, 186, 187, 188, 189, 191, 192, 193, 194, 196, 197, 198, 200, 201, 202, 204, 205, 206, 208, 209, 210, 212, 213, 215, 216, 217, 219, 220, 222, 223, 225, 226, 227, 229, 230, 232, 233, 235, 236, 238, 239, 241, 242, 244, 245, 247, 249, 250, 252, 253, 255, 257, 258, 260, 261, 263, 265, 266, 268, 270, 271, 273, 275, 276, 278, 280, 281, 283, 285, 287, 288, 290, 292, 294, 295, 297, 299, 301, 302, 304, 306, 308, 310, 312, 313, 315, 317, 319, 321, 323, 325, 327, 328, 330, 332, 334, 336, 338, 340, 342, 344, 346, 348, 350, 352, 354, 356, 358, 360, 362, 364, 366, 368, 370, 372, 374, 377, 379, 381, 383, 385, 387, 389, 391, 394, 396, 398, 400, 402, 404, 407, 409, 411, 413, 416, 418, 420, 422, 425, 427, 429, 431, 434, 436, 438, 441, 443, 445, 448, 450, 452, 455, 457, 459, 462, 464, 467, 469, 472, 474, 476, 479, 481, 484, 486, 489, 491, 494, 496, 499, 501, 504, 506, 509, 511, 514, 517, 519, 522, 524, 527, 529, 532, 535, 537, 540, 543, 545, 548, 551, 553, 556, 559, 561, 564, 567, 570, 572, 575, 578, 581, 583, 586, 589, 592, 594, 597, 600, 603, 606, 609, 611, 614, 617, 620, 623, 626, 629, 632, 635, 637, 640, 643, 646, 649, 652, 655, 658, 661, 664, 667, 670, 673, 676, 679, 682, 685, 688, 691, 694, 698, 701, 704, 707, 710, 713, 716, 719, 722, 726, 729, 732, 735, 738, 742, 745, 748, 751, 754, 758, 761, 764, 767, 771, 774, 777, 781, 784, 787, 790, 794, 797, 800, 804, 807, 811, 814, 817, 821, 824, 828, 831, 834, 838, 841, 845, 848, 852, 855, 859, 862, 866, 869, 873, 876, 880, 883, 887, 890, 894, 898, 901, 905, 908, 912, 916, 919, 923, 927, 930, 934, 938, 941, 945, 949, 952, 956, 960, 964, 967, 971, 975, 979, 982, 986, 990, 994, 998,1001,1005,1009,1013,1017,1021,1025,1028,1032,1036,1040,1044,1048,1052,1056, 1060,1064,1068,1072,1076,1080,1084,1088,1092,1096,1100,1104,1108,1112,1116,1120, 1124,1128,1132,1137,1141,1145,1149,1153,1157,1162,1166,1170,1174,1178,1183,1187, 1191,1195,1200,1204,1208,1212,1217,1221,1225,1230,1234,1238,1243,1247,1251,1256, 1260,1264,1269,1273,1278,1282,1287,1291,1295,1300,1304,1309,1313,1318,1322,1327, 1331,1336,1340,1345,1350,1354,1359,1363,1368,1372,1377,1382,1386,1391,1396,1400, 1405,1410,1414,1419,1424,1428,1433,1438,1443,1447,1452,1457,1462,1466,1471,1476, 1481,1486,1490,1495,1500,1505,1510,1515,1520,1524,1529,1534,1539,1544,1549,1554, 1559,1564,1569,1574,1579,1584,1589,1594,1599,1604,1609,1614,1619,1624,1629,1634, 1639,1644,1649,1655,1660,1665,1670,1675,1680,1685,1691,1696,1701,1706,1711,1717, 1722,1727,1732,1738,1743,1748,1753,1759,1764,1769,1775,1780,1785,1791,1796,1801, 1807,1812,1818,1823,1828,1834,1839,1845,1850,1856,1861,1867,1872,1878,1883,1889, 1894,1900,1905,1911,1916,1922,1927,1933,1939,1944,1950,1956,1961,1967,1972,1978, 1984,1989,1995,2001,2007,2012,2018,2024,2030,2035,2041,2047,2053,2058,2064,2070, 2076,2082,2087,2093,2099,2105,2111,2117,2123,2129,2135,2140,2146,2152,2158,2164, 2170,2176,2182,2188,2194,2200,2206,2212,2218,2224,2231,2237,2243,2249,2255,2261, 2267,2273,2279,2286,2292,2298,2304,2310,2317,2323,2329,2335,2341,2348,2354,2360, 2366,2373,2379,2385,2392,2398,2404,2411,2417,2423,2430,2436,2443,2449,2455,2462, 2468,2475,2481,2488,2494,2501,2507,2514,2520,2527,2533,2540,2546,2553,2559,2566, 2572,2579,2586,2592,2599,2605,2612,2619,2625,2632,2639,2645,2652,2659,2666,2672, 2679,2686,2693,2699,2706,2713,2720,2726,2733,2740,2747,2754,2761,2767,2774,2781, 2788,2795,2802,2809,2816,2823,2830,2837,2844,2850,2857,2864,2871,2878,2885,2893, 2900,2907,2914,2921,2928,2935,2942,2949,2956,2963,2970,2978,2985,2992,2999,3006, 3013,3021,3028,3035,3042,3049,3057,3064,3071,3078,3086,3093,3100,3108,3115,3122, 3130,3137,3144,3152,3159,3166,3174,3181,3189,3196,3204,3211,3218,3226,3233,3241, 3248,3256,3263,3271,3278,3286,3294,3301,3309,3316,3324,3331,3339,3347,3354,3362, 3370,3377,3385,3393,3400,3408,3416,3423,3431,3439,3447,3454,3462,3470,3478,3486, 3493,3501,3509,3517,3525,3533,3540,3548,3556,3564,3572,3580,3588,3596,3604,3612, 3620,3628,3636,3644,3652,3660,3668,3676,3684,3692,3700,3708,3716,3724,3732,3740, 3749,3757,3765,3773,3781,3789,3798,3806,3814,3822,3830,3839,3847,3855,3863,3872, 3880,3888,3897,3905,3913,3922,3930,3938,3947,3955,3963,3972,3980,3989,3997,4006, 4014,4022,4031,4039,4048,4056,4064,4095,4095,4095,4095,4095,4095,4095,4095,4095]

img_from_10bit(dat, width, height) = begin
    x = [convert(Array{UInt16}, dat[i:5:end]) for i in 1:5]
    img = Vector{UInt16}(undef, width*height)
    img[1:4:end] = x[1] .<< 2 .+ x[2] .>>> 6
    img[2:4:end] = (x[2] .& 0b111111) .<< 4 .+ x[3] .>>> 4
    img[3:4:end] = (x[3] .& 0b1111) .<< 6 .+ x[4] .>>> 2
    img[4:4:end] = (x[4] .& 0b11) .<< 8 .+ x[5]
    reshape(_LinLUT[img .+ 1], (width, height))
end

cine_info(filename) = begin
    open(filename, "r") do f
        info1 = (;
                 typeidx = read(f, UInt16) |> Int,
                 headersize = read(f, UInt16) |> Int,
                 compression = read(f, UInt16) |> Int,
                 version = read(f, UInt16) |> Int,
                 firstmovieimage = read(f, Int32) |> Int,
                 totalimagecount = read(f, UInt32) |> Int,
                 firstimageno = read(f, Int32) |> Int,
                 imagecount = read(f, UInt32) |> Int,
                 offimageheader = read(f, UInt32) |> Int,
                 offsetup = read(f, UInt32) |> Int,
                 offimageoffsets = read(f, UInt32) |> Int
                )
        seek(f, info1.offimageheader)
        info2 = (;
                 biSize = read(f, UInt32) |> Int,
                 biWidth = read(f, UInt32) |> Int,
                 biHeight = read(f, UInt32) |> Int
                )
        (;info1..., info2...)
    end
end

_read_offimageoffsets(fileio) = begin
    seekstart(fileio)
    offimageheader, offimageoffsets =
        let
            typeidx = read(fileio, UInt16)
            headersize = read(fileio, UInt16)
            compression = read(fileio, UInt16)
            version = read(fileio, UInt16)
            firstmovieimage = read(fileio, Int32)
            totalimagecount = read(fileio, UInt32)
            firstimageno = read(fileio, Int32)
            imagecount = read(fileio, UInt32)
            offimageheader = read(fileio, UInt32)
            offsetup = read(fileio, UInt32)
            offimageoffsets = read(fileio, UInt32)
            offimageheader, offimageoffsets
        end
    seek(fileio, offimageheader)
    width, height =
        let
            biSize = read(fileio, UInt32)
            biWidth = read(fileio, UInt32)
            biHeight = read(fileio, UInt32)
            biWidth, biHeight
        end
    (; offimageoffsets, width, height)
end

_read_offset(fileio, offimageoffsets, num::Integer) = begin
    seek(fileio, offimageoffsets + 8 * (num-1))
    read(fileio, UInt64)
end

_read_offset(fileio, offimageoffsets, num::UnitRange) = begin
    seek(fileio, offimageoffsets + 8 * (num.start-1))
    [read(fileio, UInt64) for _ in 1:length(num)]
end

_read_cine_dat(fileio, offset) = begin
    seek(fileio, offset)
    annotationsize = read(fileio, UInt32)
    skip(fileio, annotationsize-8)
    imagesize = read(fileio, UInt32)
    read(fileio, imagesize)
end

_read_cine_dat(fileio, offimageoffsets, n) =
    _read_cine_dat(fileio, _read_offset(fileio, offimageoffsets, n))

_read_cine_img(fileio, offimageoffsets, width, height, n) =
    img_from_10bit(_read_cine_dat(fileio, offimageoffsets, n), width, height)

fromcine(filename, num::Integer) =
    open(filename, "r") do f
        offimageoffsets, width, height = _read_offimageoffsets(f)
        _read_cine_img(f, offimageoffsets, width, height, num)
    end

fromcine(filename, num::UnitRange; prgrs=true) =
    open(filename, "r") do f
        offimageoffsets, width, height = _read_offimageoffsets(f)
        if prgrs
            ProgressMeter.ijulia_behavior(:clear)
            p = Progress(length(num); showspeed=true)
            [(next!(p; showvalues=[(:i, n), (:total, num)]);
              _read_cine_img(f, offimageoffsets, width, height, n)) for n in num] | vary
        else
            [_read_cine_img(f, offimageoffsets, width, height, n) for n in num] | vary
        end
    end

fromcine(filename; prgrs=true) = begin
    imagecount = open(filename, "r") do f
        typeidx = read(f, UInt16)
        headersize = read(f, UInt16)
        compression = read(f, UInt16)
        version = read(f, UInt16)
        firstmovieimage = read(f, Int32)
        totalimagecount = read(f, UInt32)
        firstimageno = read(f, Int32)
        imagecount = read(f, UInt32)
    end
    fromcine(filename, 1:imagecount; prgrs)
end

_force_ext(filename::AbstractString, ext::AbstractString, forcename::Bool) =
        (forcename || "." * ext == splitext(filename)[2]
         ? filename : filename * "." * ext)

cinetowbf(cinefile, wbffile; prgrs=true) =
begin
    open(_force_ext(cinefile, "cine", false), "r") do fin

        typeidx = read(fin, UInt16)
        headersize = read(fin, UInt16)
        compression = read(fin, UInt16)
        version = read(fin, UInt16)
        firstmovieimage = read(fin, Int32)
        totalimagecount = read(fin, UInt32)
        firstimageno = read(fin, Int32)
        imagecount = read(fin, UInt32)
        offimageoffsets, width, height = _read_offimageoffsets(fin)

        open(_force_ext(wbffile, "wbf", false), "w") do fout
            write(fout,
                  0x0203,
                  UInt16(3),
                  UInt32(imagecount),
                  UInt32(height),
                  UInt32(width))
            if prgrs
                ProgressMeter.ijulia_behavior(:clear)
                p = Progress(imagecount; showspeed=true)
                for n in 1:imagecount
                    next!(p; showvalues=[(:i,n), (:total,imagecount)])
                    write(fout,
                          _read_cine_img(fin,
                                         offimageoffsets,
                                         width,
                                         height,
                                         n))
                end
            else
                for n in 1:imagecount
                    write(fout,
                          _read_cine_img(fin,
                                         offimageoffsets,
                                         width,
                                         height,
                                         n))
                end
            end
        end
        nothing
    end
end
