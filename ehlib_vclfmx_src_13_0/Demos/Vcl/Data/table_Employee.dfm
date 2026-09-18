object MemTableData: TMemTableDataEh
  object DataStruct: TMTDataStructEh
    object EmpNo: TMTNumericDataFieldEh
      FieldName = 'EmpNo'
      NumericDataType = fdtAutoIncEh
      AutoIncrement = False
      DisplayLabel = 'EmpNo'
      DisplayWidth = 10
      currency = False
      Precision = 15
    end
    object LastName: TMTStringDataFieldEh
      FieldName = 'LastName'
      StringDataType = fdtWideStringEh
      DisplayLabel = 'LastName'
      DisplayWidth = 20
      Transliterate = True
    end
    object FirstName: TMTStringDataFieldEh
      FieldName = 'FirstName'
      StringDataType = fdtWideStringEh
      DisplayLabel = 'FirstName'
      DisplayWidth = 15
      Size = 15
      Transliterate = True
    end
    object PhoneExt: TMTStringDataFieldEh
      FieldName = 'PhoneExt'
      StringDataType = fdtWideStringEh
      DisplayLabel = 'PhoneExt'
      DisplayWidth = 4
      Size = 4
      Transliterate = True
    end
    object HireDate: TMTDateTimeDataFieldEh
      FieldName = 'HireDate'
      DateTimeDataType = fdtDateTimeEh
      DisplayLabel = 'HireDate'
      DisplayWidth = 18
    end
    object Salary: TMTNumericDataFieldEh
      FieldName = 'Salary'
      NumericDataType = fdtFloatEh
      AutoIncrement = False
      DisplayLabel = 'Salary'
      DisplayWidth = 10
      currency = False
      Precision = 15
    end
  end
  object RecordsList: TRecordsListEh
    Data = (
      (
        53
        'Baldwin'
        'Dana'
        '234'
        32588d
        33400.000000000000000000)
      (
        1
        'Nelson'
        'Roberto'
        '250'
        32505d
        40000.000000000000000000)
      (
        2
        'Young'
        'Bruce'
        '233'
        32505d
        55500.000000000000000000)
      (
        3
        'Lambert'
        'Kim'
        '22'
        32545d
        25000.000000000000000000)
      (
        4
        'Johnson'
        'Leslie'
        '410'
        32603d
        25050.000000000000000000)
      (
        5
        'Forest'
        'Phil'
        '229'
        32615d
        25050.000000000000000000)
      (
        6
        'Weston'
        'K. J.'
        '34'
        32890d
        33292.937500000000000000)
      (
        7
        'Lee'
        'Terri'
        '256'
        32994d
        45332.000000000000000000)
      (
        8
        'Hall'
        'Stewart'
        '227'
        33028d
        34482.625000000000000000)
      (
        9
        'Young'
        'Katherine'
        '231'
        33038d
        24400.000000000000000000)
      (
        10
        'Papadopoulos'
        'Chris'
        '887'
        32874d
        25050.000000000000000000)
      (
        11
        'Fisher'
        'Pete'
        '888'
        33128d
        23040.000000000000000000)
      (
        12
        'Bennet'
        'Ann'
        '5'
        33270d
        34482.800000000000000000)
      (
        13
        'De Souza'
        'Roger'
        '288'
        33287d
        25500.000000000000000000)
      (
        14
        'Baldwin'
        'Janet'
        '2'
        33318d
        23300.000000000000000000)
      (
        15
        'Reeves'
        'Roger'
        '6'
        33353d
        33620.000000000000000000)
      (
        16
        'Stansbury'
        'Willie'
        '7'
        33353d
        39224.000000000000000000)
      (
        17
        'Phong'
        'Leslie'
        '216'
        33392d
        40350.000000000000000000)
      (
        18
        'Ramanathan'
        'Ashok'
        '209'
        33451d
        33292.940000000000000000)
      (
        19
        'Steadman'
        'Walter'
        '210'
        33459d
        19599.000000000000000000)
      (
        20
        'Nordstrom'
        'Carol'
        '420'
        33513d
        4500.000000000000000000)
      (
        21
        'Leung'
        'Luke'
        '3'
        33652d
        34500.000000000000000000)
      (
        22
        'O'#39'Brien'
        'Sue Anne'
        '877'
        33686d
        31275.000000000000000000)
      (
        23
        'Burbank'
        'Jennifer M.'
        '289'
        33709d
        45332.000000000000000000)
      (
        24
        'Sutherland'
        'Claudia'
        nil
        33714d
        35699.000000000000000000)
      (
        25
        'Bishop'
        'Dana'
        '290'
        33756d
        45000.000000000000000000)
      (
        26
        'MacDonald'
        'Mary S.'
        '477'
        33756d
        35699.000000000000000000)
      (
        27
        'Williams'
        'Randy'
        '892'
        33824d
        28900.000000000000000000)
      (
        28
        'Bender'
        'Oliver H.'
        '255'
        33885d
        36799.000000000000000000)
      (
        29
        'Cook'
        'Kevin'
        '894'
        34001d
        35500.000000000000000000)
      (
        30
        'Brown'
        'Kelly'
        '202'
        34004d
        27000.000000000000000000)
      (
        31
        'Ichida'
        'Yuki'
        '22'
        34004d
        25689.000000000000000000)
      (
        32
        'Page'
        'Mary'
        '845'
        34071d
        48000.000000000000000000)
      (
        33
        'Parker'
        'Bill'
        '247'
        34121d
        35000.000000000000000000)
      (
        34
        'Yamamoto'
        'Takashi'
        '23'
        34151d
        32500.000000000000000000)
      (
        35
        'Ferrari'
        'Roberto'
        '1'
        34162d
        40500.000000000000000000)
      (
        36
        'Yanowski'
        'Michael'
        '492'
        34190d
        44000.000000000000000000)
      (
        37
        'Glon'
        'Jacques'
        nil
        34204d
        24855.000000000000000000)
      (
        38
        'Johnson'
        'Scott'
        '265'
        34225d
        30588.990000000000000000)
      (
        39
        'Green'
        'T.J.'
        '218'
        34274d
        36000.000000000000000000)
      (
        40
        'Osborne'
        'Pierre'
        nil
        34337d
        35600.000000000000000000)
      (
        41
        'Montgomery'
        'John'
        '820'
        34423d
        35699.000000000000000000)
      (
        42
        'Guckenheimer'
        'Mark'
        '221'
        34456d
        32000.000000000000000000)
      (
        43
        'Baldwin'
        'Janet'
        '234'
        31127d
        29400.000000000000000000)
      (
        44
        'NewL1'
        nil
        nil
        nil
        nil)
      (
        45
        'NewL2'
        nil
        nil
        nil
        nil)
      (
        46
        'NewL3'
        nil
        nil
        nil
        nil)
      (
        47
        'NewL44'
        nil
        nil
        nil
        nil)
      (
        48
        'Newl45'
        nil
        nil
        nil
        nil)
      (
        49
        'Newl46'
        nil
        nil
        nil
        nil)
      (
        50
        'Newl47'
        nil
        nil
        nil
        nil))
  end
end
