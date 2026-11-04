use("directorio_talento");

db.perfiles.find();
skills[2]

estudios[carrera]
estudios.carrera
estudios[{carrera}]
estudios{carrera}
{"estudios.carrera":1}



estudios: [
    {
      institucion: 'Duoc UC',
      carrera: 'Ingenieria en Informatica',
      estado: 'En curso'
    },
    {
      institucion: 'U de Chile',
      carrera: 'Bioingenieria',
      estado: 'Terminada'
    }
  ]
estudios[1].carrera



//pirmer ejeficico

use("directorio_talento");

db.perfiles.countDocuments();

//filtramos y contamos los que cumplan este criterio

use("directorio_talento");

db.perfiles.countDocuments(
    {
        seccion: '003D'
    }
);

use("directorio_talento");

db.perfiles.countDocuments(
    {
        seccion: '004D'
    }
);

use("directorio_talento");
db.perfiles.countDocuments(
    {seccion: {$exists: false}    
});