
import * as admin from 'firebase-admin';
import { getDistance } from 'geolib';


const diferenciaValidaEntreValoraciones = 60;

export function calculateAge(birthDateInSeconds: number) {

    var timeStamp = admin.firestore.Timestamp.now().seconds;

    var ageInSeconds = timeStamp - birthDateInSeconds;
    var age = (ageInSeconds / 86400) / 365;
    return age;


}

export function calcularlongitudMaxima(dato: number, distancia: number): number[] {



    var longitudTemporal: number = parseFloat(dato.toFixed(1));
    console.log(`datoString  sin punto ${longitudTemporal}`);





    var resultado: number[] = [];
    resultado.push(longitudTemporal)



    longitudTemporal = longitudTemporal + 360;

    for (var i: number = 0; i < distancia; i++) {
        longitudTemporal = longitudTemporal + 0.1
        longitudTemporal = parseFloat(longitudTemporal.toFixed(1));
        resultado.push(longitudTemporal)




    }

    for (var i: number = 1; i < resultado.length; i++) {
        longitudTemporal = parseFloat(longitudTemporal.toFixed(1));
        var result = resultado[i] - 360;
        resultado[i] = parseFloat(result.toFixed(1));



    }

    console.log(`longitudesMaximas  ${resultado}`);


    return resultado;




}
export function calcularlongitudMinima(dato: number, distancia: number): number[] {
    var resultado: number[] = [];
    var longitudTemporal: number = parseFloat(dato.toFixed(1));



    longitudTemporal = longitudTemporal + 360;

    for (var i: number = 0; i < distancia; i++) {
        longitudTemporal = longitudTemporal - 0.1
        longitudTemporal = parseFloat(longitudTemporal.toFixed(1));
        resultado.push(longitudTemporal)




    }

    for (var i: number = 0; i < resultado.length; i++) {
        longitudTemporal = parseFloat(longitudTemporal.toFixed(1));
        var result = resultado[i] - 360;
        resultado[i] = parseFloat(result.toFixed(1));



    }


    console.log(`lomgitudesMinimas  ${resultado}`);


    return resultado;




}




export function calcularLatitudMaxima(dato: number, distancia: number): number {
    var latitudTemporal: number = parseFloat(dato.toFixed(1));


    latitudTemporal = latitudTemporal + 90;

    for (var i: number = 0; i < distancia; i++) {
        latitudTemporal = latitudTemporal + 0.1


        latitudTemporal = parseFloat(latitudTemporal.toFixed(1));



    }

    latitudTemporal = latitudTemporal - 90;
    latitudTemporal = parseFloat(latitudTemporal.toFixed(1));





    console.log(`lM  ${latitudTemporal}`);



    return latitudTemporal;




}
export function calcularLatitudMinima(dato: number, distancia: number): number {
    var latitudTemporal: number = parseFloat(dato.toFixed(1));


    latitudTemporal = latitudTemporal + 90;

    for (var i: number = 0; i < distancia; i++) {
        latitudTemporal = latitudTemporal - 0.1


        latitudTemporal = parseFloat(latitudTemporal.toFixed(1));



    }

    latitudTemporal = latitudTemporal - 90;
    latitudTemporal = parseFloat(latitudTemporal.toFixed(1));





    console.log(`latitudMaxima  ${latitudTemporal}`);



    return latitudTemporal;












}

/**
 * Solicita los perfiles al backend ordenandolos por latitud (max, min), y a su vez usa el metodo array contains para encontrar por longitud
 * 
 * devuelve una lista de perfiles ordenados por ultima valoracion
 * 
 * La funcion se encarga de filtrar a todos los perfiles que hayan valorado al usuario, que esten bloqueados, que tengan una conversacion....etc
 * 
 * 
 * 
 * 
 * 
 * 
 * @param distancia 
 * @param ambosSexos 
 * @param edadInicial 
 * @param edadFinal 
 * @param sexo 
 * @param idSolicitante 
 * @param documentoUsuario 
 * @param longitudes 
 * @param latitudMaxima 
 * @param latitudMinima 
 * @param latitud 
 * @param longitud 
 * @returns 
 */

export async function solicitarUsuariosFirestore(distancia: number,
    ambosSexos: boolean, edadInicial: number, edadFinal: number, sexo: boolean,
    idSolicitante: string, documentoUsuario: FirebaseFirestore.DocumentData, longitudes: number[], latitudMaxima: number, latitudMinima: number, latitud: number, longitud: number): Promise<Record<string, any>> {
    var listaPerfiles: Record<string, any>[] = [];
    var cacheIndex = 0;
    var excluirPerfil = false;


    const marcaTiempo: number = admin.firestore.Timestamp.now().seconds;
    var valoracionesActivas: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];
    var perfilesFormatoDocumento: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];
    var listaPerfilesFiltrados: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];


    var perfilesEncontrados;
    var perfiles: any[] = [];
    var longitudesCache: number[] = [];
    // valoracionesActivas = valoracionesActivas.concat(await comprobarValoracionesActivas(marcaTiempo, idSolicitante));
    //valoracionesActivas = valoracionesActivas.concat(await comprobarConversaciones(idSolicitante));
    //valoracionesActivas = valoracionesActivas.concat(await comprobarHistorialValoraciones(idSolicitante));

    console.log(`usuarios ya valorados: ${valoracionesActivas.length}`);

    for (var i = 0; i < longitudes.length; i++) {

        if (longitudesCache.length < 10) {
            longitudesCache.push(longitudes[cacheIndex]);


        }

        if (longitudesCache.length === 10 || i === longitudes.length - 1) {
            if (ambosSexos === true) {
                perfilesEncontrados = await admin.firestore().collection("usuarios").where("usuarioVisible", "==", true).where("lat", ">=", latitudMinima).where("lat", "<=", latitudMaxima).where("longitud", "array-contains-any", longitudesCache).get();
                perfiles = perfiles.concat(perfilesEncontrados.docs);
                longitudesCache = [];
            }
            else {
                perfilesEncontrados = await admin.firestore().collection("usuarios").where("usuarioVisible", "==", true).where("Sexo", "==", sexo).where("lat", ">=", latitudMinima).where("lat", "<=", latitudMaxima).where("longitud", "array-contains-any", longitudesCache).get();
                perfiles = perfiles.concat(perfilesEncontrados.docs);
                longitudesCache = [];
            }

        }
        cacheIndex = cacheIndex + 1;

    }

    cacheIndex = 0;

    if (perfiles.length > 0) {
        perfilesFormatoDocumento = perfilesFormatoDocumento.concat(perfiles);
    }




    perfilesFormatoDocumento = perfilesFormatoDocumento.sort((a, b) => a.data()["ultimaValoracion"] - b.data()["ultimaValoracion"])
    perfilesFormatoDocumento = perfilesFormatoDocumento.slice(0, 15)

    for (var i = 0; i < perfilesFormatoDocumento.length; i++) {
        for (var z = 0; z < valoracionesActivas.length; z++) {
            var age = calculateAge(perfilesFormatoDocumento[i].data()["fechaNacimiento"])


            if ((perfilesFormatoDocumento[i].id === valoracionesActivas[z].data()["idDestino"])) {

                console.log(`idDestino : ${perfilesFormatoDocumento[i].id}`);
                excluirPerfil = true;
            }
            if ((perfilesFormatoDocumento[i].id === valoracionesActivas[z].data()["idPerfilHistorial"])) {

                var sePuedeMostrar = comprobarTiempoEnHistorialValoraciones(marcaTiempo, valoracionesActivas[z].data()["Time"])

                if (sePuedeMostrar === false) {
                    excluirPerfil = true;

                }

            }
            if ((perfilesFormatoDocumento[i].id === valoracionesActivas[z].data()["Id emisor"])) {
                console.log(`id emisor  ${perfilesFormatoDocumento[i].id}`);

                excluirPerfil = true;
            } if ((perfilesFormatoDocumento[i].id === valoracionesActivas[z].data()["idRemitente"])) {
                console.log(`idRemitente ${perfilesFormatoDocumento[i].id}`);

                excluirPerfil = true;
            }
        }
        if (excluirPerfil === false) {
            listaPerfilesFiltrados.push(perfilesFormatoDocumento[i])
        }
        excluirPerfil = false;

    }
    for (var e: number = 0; e < listaPerfilesFiltrados.length; e++) {
        console.log(`perfiles encontrados: ${listaPerfilesFiltrados.length}`);
        var age = calculateAge(listaPerfilesFiltrados[e].data()["fechaNacimiento"])

        if (idSolicitante !== listaPerfilesFiltrados[e].data()["id"] && age > edadInicial && age < edadFinal) {
            var distanciaDeUsuario: number = getDistance({ "latitude": latitud, "longitude": longitud }, { "latitude": listaPerfilesFiltrados[e].data()["posicionLat"], "longitude": listaPerfilesFiltrados[e].data()["posicionLon"] });


            if (documentoUsuario.get("Ajustes")["mostrarPerfil"] === true) {
                listaPerfiles.push({
                    "identificador": listaPerfilesFiltrados[e].data()["id"], "nombre": listaPerfilesFiltrados[e].data()["Nombre"], "fechaNacimiento": listaPerfilesFiltrados[e].data()["fechaNacimiento"],
                    "IMAGENPERFIL1": listaPerfilesFiltrados[e].data()["IMAGENPERFIL1"],
                    "IMAGENPERFIL2": listaPerfilesFiltrados[e].data()["IMAGENPERFIL2"],
                    "IMAGENPERFIL3": listaPerfilesFiltrados[e].data()["IMAGENPERFIL3"],
                    "IMAGENPERFIL4": listaPerfilesFiltrados[e].data()["IMAGENPERFIL4"],
                    "IMAGENPERFIL5": listaPerfilesFiltrados[e].data()["IMAGENPERFIL5"],
                    "IMAGENPERFIL6": listaPerfilesFiltrados[e].data()["IMAGENPERFIL6"],
                    "mediaTotal": listaPerfilesFiltrados[e].data()["mediaTotal"],
                    "verificado": listaPerfilesFiltrados[e].data()["verificado"]["status"],
                    "distancia": distanciaDeUsuario / 1000,
                    "Descripcion": listaPerfilesFiltrados[e].data()["Descripcion"],
                    "filtrosUsuario": listaPerfilesFiltrados[e].data()["filtros usuario"],

                })
            }




        }
    }
    return { "listaPerfiles": listaPerfiles, "listaVacia": listaPerfiles.length > 0 ? false : true, };
}

export async function comprobarValoracionesActivas(marcaTiempo: number, idUsuario: string) {
    var valoracionesActivas: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];

    var valoracionesActivasUsuario1 = await admin.firestore().collection("valoracionesPrivadas").where("caducidad", ">", marcaTiempo).where("Id emisor", "==", idUsuario).get();
    var valoracionesActivasUsuario2 = await admin.firestore().collection("valoracionesPrivadas").where("caducidad", ">", marcaTiempo).where("idDestino", "==", idUsuario).get();
    valoracionesActivas = valoracionesActivas.concat(valoracionesActivasUsuario1.docs)
    valoracionesActivas = valoracionesActivas.concat(valoracionesActivasUsuario2.docs)
    return valoracionesActivas;

}

export async function comprobarConversaciones(idUsuario: string) {
    var conversaciones: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];

    var usuariosConConversaciones = await admin.firestore().collection("usuarios").doc(idUsuario).collection("conversaciones").get();
    if (usuariosConConversaciones.docs.length > 0) {
        conversaciones = conversaciones.concat(usuariosConConversaciones.docs)
    }

    return conversaciones;

}

export async function comprobarHistorialValoraciones(idUsuario: string) {
    var historial: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];

    var historialValoraciones = await admin.firestore().collection("usuarios").doc(idUsuario).collection("historialValoraciones").get();
    if (historialValoraciones.docs.length > 0) {
        historial = historial.concat(historialValoraciones.docs)
    }

    return historial;

}



export function comprobarTiempoEnHistorialValoraciones(marcaTiempo: number, fechaEnHistorial: number): boolean {

    var diferencia = marcaTiempo - fechaEnHistorial
    if (diferencia > diferenciaValidaEntreValoraciones) {
        return true;
    }
    else {
        return false;
    }
}