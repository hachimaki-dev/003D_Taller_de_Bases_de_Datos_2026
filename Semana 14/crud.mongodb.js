use('directorio_talento');
db.perfiles.find(
    {
        seccion : '003D'
    }
);


//Creemos la coleccione
use('directorio_talento');
db.empresas.insertMany(
    [
      {
        nombre : "Fazbear", 
        rubro: "Comida rápida", 
        empleados: 3, 
        ciudad: "Puerto Montt", 
        creado_por: "Carlos Orellana"
      },
      {
        nombre : "Apovet", 
        rubro: "Medicina Veterinaria", 
        empleados: 4, 
        ciudad: "Puerto Montt", 
        creado_por: "Carlos Orellana"
      }
    ]
);

use('directorio_talento');
db.empresas.find();



use('directorio_talento');
db.ofertas.insertMany(
    [
        {
            cargo: 'Ingeniero de Software', 
            empresa : 'Fallabela', modalidad : 'Hibrido', 
            sueldo: 2500000, 
            vacantes: 1, 
            requisitos: [
            "SCRUM",
            "Kotlin",
            "Flutter",
            "PostgressDB",
            "AZURE",
            "AWS",
            "Symphony",
            "React",
            "EXPRESS",
            "VUE",
            "Git"
        ], 
        activa: true , 
        creado_por : "Carlos Orellana"
        },
        {
            cargo: 'Desarrollador FULLSTACK', 
            empresa : 'Fallabela', 
            modalidad : 'Remoto', 
            sueldo: 1600000, 
            vacantes: 2, 
            requisitos: [
                {
                    tecnologia: "Laravel",
                    años_experiencia : 5,
                    seniority : "junior"
                },
                {
                    tecnologia: "Java Spring",
                    años_experiencia : 1,
                    seniority : "junior"
                }
        ], 
        activa: true , 
        creado_por : "Carlos Orellana"
        }
    ]
);


//Los voy a co sultar todos
use('directorio_talento');
db.ofertas.find();

//Operador $GT
use('directorio_talento');
db.ofertas.find(
    {
        sueldo: 100
    }
);

//Si quiero traerme los mayores a 1000000
use('directorio_talento');
db.ofertas.find(
    {
        sueldo: {$gt : 1000000}
    }
);

//Menos de un millon
use('directorio_talento');
db.ofertas.find(
    {
        sueldo: {$lt : 1000000}
    }
);

use('directorio_talento');
db.ofertas.find(
    {
       //Not equal
       modalidad : {$nin : ['remoto', 'Remoto']}
    }
);


//Que sea remoto o hibrido
use('directorio_talento');
db.ofertas.find({
    $or: [
        { modalidad: "remoto" },
         { modalidad: "hibrido" }
    ]
});