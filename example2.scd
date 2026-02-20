// Calculo
(
    var string, mass, connections, exitationPoint, readoutPoint;

    // descripcion de objeto virtual
    // wavespeed, rigidez, amortiguacion, 
    // amortiguadion dependiente de frecuencia, 
    // "boundary condition": Clamped, Supported, Fixed
    string = Resonator1D(200, 1, 0.5, 0.5, 'CC');

    // masa de la cuerda
    mass = Array2D.fromArray(1, 2, [1, 1]);

    // conecciones entre cuerdas
    connections = Array2D.fromArray(1, 2, [0.1, 0.9]);

    // punto de exitacion
    exitationPoint = Array2D.fromArray(1, 1, [0.33]);

    // punto de lectura
    readoutPoint = Array2D.fromArray(1, 1, [0.66]);

    // construccion del sistema
    ~network = ResonatorNetwork(
        string, mass, connections, exitationPoint, readoutPoint
    ).calcModalData(
        gain: 40.dbamp, minFreq: 25, maxFreq: 16000, incl: "yynn",
        pathname: thisProcess.nowExecutingPath().dirname +/+ "stringData.json"
    )
)

(
    var string1;
    string1 = Resonator1D.new(200, 1, 0.5, 0.5, 'CC');
    string1
)   
