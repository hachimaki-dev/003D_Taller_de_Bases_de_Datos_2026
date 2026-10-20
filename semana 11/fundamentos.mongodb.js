
use("tinder_luis");

db.vitrina.insertOne({
    "nombre" : "Pepita",
    "fotos" : [
        "https://tse3.mm.bing.net/th/id/OIP.9a_G3NOa4kgvrM6uHxQAMAHaHT?r=0&w=1280&h=1262&rs=1&pid=ImgDetMain&o=7&rm=3",
        "https://tse1.mm.bing.net/th/id/OIP.I7S7oxYKcxXQLQ368582uwHaHo?r=0&w=492&h=507&rs=1&pid=ImgDetMain&o=7&rm=3"
    ],
    "edad" :42,
    "ciudad" : "Puerto Montt",
    "descripcion" : "Me separe hace poco, de papa pig :c",
    "intereses" : ["fumar", "escuchar música", "yoga"]
});


use("tinder_luis");
db.vitrina.find();

use("tinder_luis");
db.vitrina.findAndModify({"nombre" : "Pepita"});

