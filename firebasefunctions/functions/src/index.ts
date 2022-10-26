import * as functions from "firebase-functions";

import { google } from "googleapis";
import * as admin from 'firebase-admin';
import * as getProfiles from "./solicitarUsuarios/solicitarUsuarios";

import * as claveGoogle from "./claveJSON.json";
import { isBlurhashValid } from "blurhash";
//import * as handpose from "@tensorflow-models/handpose";
//import "@tensorflow/tfjs-backend-webgl";
//import * as fp from "fingerpose";

//import * as fpg from "fingerpose-gestures";
//import getDistance from 'geolib/es/getDistance';
//import { cloudtasks } from 'googleapis/build/src/apis/cloudtasks';








const iniciarFirestore = admin.initializeApp();

admin.firestore().settings({ ignoreUndefinedProperties: true });



//const kNotAvailable = "NOT_AVAILABLE";
const kProfileNotReviewed = "PROFILE_NOT_REVIEWED";
const kProfileInReviewProcess = "PROFILE_IN_REVIEW_PROCESS";
//const kProfileReviewedSuccesfully = "PROFILE_REVIEW_SUCCESFULL";
//const kProfileRefiewedError = "PROFILE_REVIEW_ERROR";



//const { admin } = require('firebase-admin/lib/database');

// // Start writing Firebase Functions
//https://firebase.google.com/docs/functions/typescript


export const setVerificationPicture = functions.https.onCall(async (data, context) => {
    try {
        const pictureUrl: string = data["url"];

        const userId: string = data["userId"];
        await admin.firestore().collection("verificationDataCollection").doc(userId).update({ "image": pictureUrl, "status": kProfileInReviewProcess });

        return { "estado": "correcto" }
    } catch (e) {
        await notificarErroresEscuchadoresEventos({
            "estado": "error",
            "function": "setVerificationPicture",

            "mensaje": e
        });
        return { "estado": "error" }


    }


});

export const listenToVerificationState = functions.runWith({ memory: "4GB", "timeoutSeconds": 540 }).firestore.document("/verificationDataCollection/{verificationDataCollectionId}").onUpdate(async (change, context) => {

    var previous = change.before;
    var current = change.after;
    var previousReviewStatus = previous.get("status");
    var currentReviewStatus = current.get("status");


    if (previousReviewStatus !== kProfileInReviewProcess && currentReviewStatus === kProfileInReviewProcess) {
        var userPicutres: Record<string, string>[] = [];
        var userDocument = await admin.firestore().collection("usuarios").doc(current.id).get();

        var image1Map = userDocument.get("IMAGENPERFIL1");
        var image2Map = userDocument.get("IMAGENPERFIL2");
        var image3Map = userDocument.get("IMAGENPERFIL3");
        var image4Map = userDocument.get("IMAGENPERFIL4");
        var image5Map = userDocument.get("IMAGENPERFIL5");
        var image6Map = userDocument.get("IMAGENPERFIL6");

        var imageMapList = [image1Map, image2Map, image3Map, image4Map, image5Map, image6Map]
        for (let i = 0; i < imageMapList.length; i++) {
            var data = imageMapList[i]["Imagen"];
            if (data !== "vacio") {
                userPicutres.push({ "imageCode": `Image${i + 1}`, "imageLink": data })
            }
        }
        /*     imageMapList.forEach((element) => {
                 var data = element["Imagen"];
                 if (data !== "vacio") {
                     userPicutres.push(data)
                 }
             })*/

        return faceMatcher(current.id, userPicutres);


    }
    else {
        return null;
    }




})
async function faceMatcher(userId: string, userPictures: Record<string, string>[]) {
    const myConfig = {
        modelBasePath: 'file://node_modules/@vladmandic/human/models',

        face: {
            enabled: true,
            detector: { rotation: true, return: true, maxDetected: 100 },
            mesh: { enabled: true },
            description: { enabled: true },
        },
    };
   //  const model = await handpose.load();
    const Human = require('@vladmandic/human').default;
    const human = new Human(myConfig);
    await human.tf.ready();
    await human.load();

    var imageResults: Record<string, any>[] = [];


    // points to @vladmandic/human/dist/human.node.js
 //const tf = require("@tensorflow/tfjs-node")
    var verificationPicture = await admin.storage().bucket().file(`${userId}/Perfil/verificationImages/Image.jpg`).download();

    var verificationImageTensor = human.tf.node.decodeImage(verificationPicture[0])
   //    const predictions = await model.estimateHands(verificationImageTensor, false);
  //    const estimatedGestures = GE.estimate(predictions[0].landmarks, 7.5);
   // console.log(estimatedGestures)

    const referencePicture = await human.detect(verificationImageTensor);
    human.tf.dispose(verificationImageTensor)
    for (let z = 0; z < userPictures.length; z++) {
        var profilePicture = await admin.storage().bucket().file(`${userId}/Perfil/imagenes/${userPictures[z]["imageCode"]}.jpeg`).download();
        var imageDescriptor: Record<any, any> = {};



        var profilePictureTensor = human.tf.node.decodeImage(profilePicture[0])

        const currentProfilePicture = await human.detect(profilePictureTensor);
        human.tf.dispose(profilePictureTensor)
        for (let a = 0; a < referencePicture.face.length; a++) {
            for (let i = 0; i < currentProfilePicture.face.length; i++) {
                const currentEmbedding = currentProfilePicture.face[i].embedding;
                const referenceEmbedding = referencePicture.face[a].embedding;
                if (currentEmbedding !== undefined && referenceEmbedding !== undefined) {

                    const similarity = human.similarity(referenceEmbedding, currentEmbedding, { order: 2, multiplier: 25, min: 0.2, max: 0.8 });
                    console.log(`face in image with code  ${userPictures[z]["imageCode"]} is ${100 * similarity}% simmilar`);

                    var faceCode = `Face${i}`;
                    var processedSimilarity = `${100 * similarity}`
                    imageDescriptor[faceCode] = processedSimilarity;


                }
            }
        }
        var imageCode = userPictures[z]["imageCode"];
        var imageResult: Record<any, any> = {};
        imageResult[imageCode] = imageDescriptor;

        imageResults.push(imageResult)

    }

    await admin.firestore().collection("verificationDataCollection").doc(userId).update({ "results": imageResults });

    return null;


}

export const ponerInformacionAdicionalTokenRegistro = functions.https.onCall(async (data) => {
    const imei: string = data["idDispositivo"];
    const fechaAutenticacion: string = data["fechaInicioSesion"]
    const idUsuario: string = data["idUsuario"];

    return admin.auth().setCustomUserClaims(idUsuario, { "idDispositivo": imei, "fechaInicioSesion": fechaAutenticacion, })
})

export const crearStatusEnRTDB = functions.firestore.document("presenciaUsuario/{presenciaUsuarioId}").onCreate(async (usuario) => {
    const documentoUsuario = usuario;

    return admin.database().ref(`/status/${documentoUsuario.id}`).set({ "Hora": admin.firestore.Timestamp.now().toMillis(), "Status": "Conectado", "esperandoDispositivo": false, "fechaRevocacion": 0, "idDispositivo": documentoUsuario.get("idDispositivo"), "nombreDispositivo": documentoUsuario.get("nombreDispositivo"), "idUsuario": documentoUsuario.id, "sesionCerrada": false })
})


///Eviaomos notificacion de mensaje por Firebase Messaging cada vez que enviamos un mensaje, 
///estas notificaciones estan pensadas para cuando el usuario no tiene la aplicacion abierta y necesitamos mantenerle al tanto de sus conversaciones en la aplicacion

export const enviadorNotificacionMensaje = functions.firestore.document("/mensajes/{mensajes}").onCreate(async (mensaje) => {


    const token = mensaje.get("token");
    if (token !== null && token !== undefined) {
        if (token.length > 5) {
            await iniciarFirestore.messaging().sendToDevice(token, { data: { tipoNotificacion: "mensaje" } },
                { priority: "high", contentAvailable: true })
            return null;





        }
        else {
            return notificarErroresEscuchadoresEventos({
                "estado": "error",
                "tipo": "notificacionesPush",
                "mensaje": "error_token_no_valido"
            })


                ;
        }
    }
    else {
        return notificarErroresEscuchadoresEventos({
            "estado": "error",
            "tipo": "notificacionesPush",

            "mensaje": "error_token_no_definido"
        });
    }



})
/// Cuando se actualice el token de Firebase Messaging, si el token de notificacion del usuario 1 se refresca primero leemos todas las conversaciones de dicho usuario,
/// luego de cada conversacion sacamos a los remitentes, accedemos a su copia de las conversaciones que tienen con el usuario 1 y actalizamos el token de notificacion
///Podemos permitir que el token este vacio, de esta manera las funciones que usan Firebase Messaging no enviaran las notificaciones y devolveran un error controlado de token ivalido

/// PELIGRO



export const actualizadorTokenNotificacion = functions.firestore.document("/usuarios/{usuariosId}").onUpdate(async (cambio, context) => {

    const tokenAntiguo = cambio.before.get("tokenNotificacion");
    const tokenNuevo = cambio.after.get("tokenNotificacion");


    if (tokenNuevo !== null && tokenNuevo !== undefined) {
        if (tokenAntiguo !== tokenNuevo) {
            return iniciarFirestore.firestore().collection("usuarios").doc(cambio.after.id).collection("conversaciones").get().then(async (conversaciones) => {
                conversaciones.forEach(async (conversacion) => {
                    var idRemitenteConversacion = conversacion.get("idRemitente");
                    var idConversacionRemitente = conversacion.id;
                    await iniciarFirestore.firestore().collection("usuarios").doc(idRemitenteConversacion).collection("conversaciones").doc(idConversacionRemitente).update({ "tokenNotificacion": tokenNuevo });

                })





            })
        }
        else {
            return null;
        }
    }
    else {
        return notificarErroresEscuchadoresEventos({
            "estado": "error",
            "tipo": "notificacionesPush",

            "mensaje": "error_token_no_definido"
        })

    }



})

/**
 * Esta funcion sera usada cuando tras revocar los token de acceso a los usuarios, nos devuelve la fecha de revocacion y poemos usarla para cotrolar el acceso
 * por ejemplo podemos hacer que ese usuario necesite un token con fecha de acceso poseterior a la de la revocacion
 * 
 * @param identificadorUsuario 
 * @returns 
 * Una promesa que al completarse nos devuelve en segundos la fecha en la que el usuario ha sido revocado,
 */

async function obtenerFechaRevocacion(identificadorUsuario: string): Promise<number> {
    const uid: string = identificadorUsuario;
    if (uid !== undefined) {
        if (uid !== null) {
            const existeUsuario: boolean = await (await admin.firestore().collection("usuarios").doc(uid).get()).exists;
            if (existeUsuario === true) {
                const recordUsuario: admin.auth.UserRecord = await admin.auth().getUser(uid);
                const fechaRevocacion: any = new Date(recordUsuario.tokensValidAfterTime!).getTime() / 1000;

                return fechaRevocacion;

            }
            else {
                throw Error("usuario_no_existe");
            }
        }
        else {
            // el uid es nulo
            throw Error("uid_nulo");
        }
    }
    else {

        throw Error("uid_no_definido");
    }




}
/**
 * NOTA: solo se debe llamar en las funciones que sean escuchadores de eventos en firestore y RealTime Database (onCreate, onDelete, onUpdate)
 * 
 * La funcion [notificarErroresEscuchadoresEventos] sirve para rastrear errores que pueden ocurrir en este tipo de funciones internas que o son llamadas por el usuario
 * escribiendo en la coleccion erroresEscuchadoresEventosFirestore los errores para su futuro analisis por el equipo de desarrollo 
 * 
 * 
 * 
 * @param constructorError
 
 */
async function notificarErroresEscuchadoresEventos(constructorError: Record<any, any>) {

    return admin.firestore().collection("erroresEscuchadoresEventosFirestore").doc().set(constructorError);
}






export const notificarMensajesFCM = functions.https.onCall((data) => {
    const token = data["token"];
    if (token.length > 5) {
        return iniciarFirestore.messaging().sendToDevice(token, { data: { tipoNotificacion: "mensaje" } },
            { priority: "high", contentAvailable: true }).then(() => {
                return 200
            })

    }
    else {
        return {
            "estado": "error",
            "tipo": "enviar_notificacion_push_mensaje",
            "mensaje": "token_no_valido"
        };
    }
})
/**
 * NOTA: Esta funcion se llama desde el cliente solo al iniciar el proceso de cerrar sesion
 * 
 * Esta  funcion revoca todos los tokens de acceso que tenia el usuario despues de que este cierre sesion 
 * Luego verifica el idToken, necesitamos que al verificar el token nos devuelva error ya que eso nos asegura que los tokens han sido revocados y no hay nada que verificar
 * tras eso podemos afirmar que la sesion se ha cerrado perceftaente y lo registramos en la base de datos 
 * 
 * 
 * @param data
 
 */


export const comprobarTokenCerrarSesion = functions.https.onCall(async (datos, context) => {
    const idToken = datos["idToken"];
    const idUsuario = datos["idUsuario"];
    await admin.auth().revokeRefreshTokens(idUsuario);
    return admin.auth().verifyIdToken(idToken, true).then(async (token) => {
        return { "estado": "error", "mensaje": "error_token_no_revocado", "tipo": "comprobarTokenCerrarSesion" }
    }).catch(async (error) => {
        // Token no valido
        if (error.code === "auth/id-token-revoked") {
            var documento = await iniciarFirestore.firestore().collection("presenciaUsuario").doc(idUsuario).get();
            var fechaRevocacion = documento.get("fechaRevocacion");
            if (fechaRevocacion === 0) {
                return admin.database().ref(`/status/${idUsuario}`).update({ "sesionCerrada": true, "Hora": admin.firestore.Timestamp.now().toMillis(), "Status": "Desconectado" })


            }
            else {
                return null
            }
        }
    });




})

/**
 * Esta funcion actualiza la presencia del usuario y tiene tres estados
 * 
 * 1 Usuario con la sesion iniciada pero desconectado       
 * Ocurre como en otras aplicaciones famosas (Instagram, Tinder, Facebook...) puedes cerrar la aplicacion pero mantener la sesion abierta en el dispositivo, la cuenta sigue ligada a un dispositivo
 * 
 * 2 Sesion cerrada     
 * Cierras tu sesion y te desconectas totalmente, puedes abrir la sesion en otro dispositivo o en el mismo ya que la cuenta que desligada de el dispositivo
 * 
 * 3 Sesion abierta y conectado     
 * El usuario esta en la aplicación y está conectado
 * 
 * 
 * NOTA: Si se detecta que un dispositivo accede a una cuenta mientras esta está ligada a otro dispositivo, se revocarán los tókenes de acceso a ambos y se mostrará una advertencia de seguridad
 * 
 */



export const actualizarEstadoFirebase = functions.database.ref("/status/{status}").onUpdate(async (change, context) => {
    const antesCambio = change.before.val();
    const despuesCambio = change.after.val();

    const statusGeneralFirestoreUsuario: admin.firestore.DocumentReference = iniciarFirestore.firestore().collection("presenciaUsuario").doc(despuesCambio.idUsuario);
    const batchEscrituraEstadoConexion: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();
    var cuentaAbiertaVariosDispositivos: boolean = false;
    const presenciaFirestore = await iniciarFirestore.firestore().collection("presenciaUsuario").doc(despuesCambio.idUsuario).get();
    const usuario = context.auth?.uid;

    if ((antesCambio.Status === despuesCambio.Status && antesCambio.Hora === despuesCambio.Hora && antesCambio.idDispositivo === despuesCambio.idDispositivo && antesCambio.nombreDispositivo === despuesCambio.nombreDispositivo)) {

        return null;
    }


    else {
        ///Caso 3 dos dispositivos acceden a la misma cuenta sin que esta se cierre entre los dos accesos

        if (despuesCambio.sesionCerrada === false && (antesCambio.idDispositivo !== despuesCambio.idDispositivo || antesCambio.nombreDispositivo !== despuesCambio.nombreDispositivo) && presenciaFirestore.get("fechaRevocacion") === 0) {

            return admin.auth().revokeRefreshTokens(usuario!).then(async (_) => {
                const fechaRevocacion = await obtenerFechaRevocacion(usuario!).catch((e) => {
                    return notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e.message, "tipo": "actualizarEstadoFirebase" })
                });
                batchEscrituraEstadoConexion.set(statusGeneralFirestoreUsuario, { estaConectado: false, "id": despuesCambio.key, "idDispositivo": "", "nombreDispositivo": "", "sesionCerrada": true, "fechaRevocacion": fechaRevocacion, "idToken": presenciaFirestore.get("idToken") });
                cuentaAbiertaVariosDispositivos = true;
                return batchEscrituraEstadoConexion.commit().catch((e) => {
                    return notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e.message, "tipo": "actualizarEstadoFirebase" })
                });;

            });


        }
        else {
            if (cuentaAbiertaVariosDispositivos === false) {
                ///El usuario sigue conectado con el mismo dispositivo pero cambia el token de acceso (cambia cada hora)

                if (despuesCambio.Status === "Conectado") {

                    batchEscrituraEstadoConexion.set(statusGeneralFirestoreUsuario, { estaConectado: true, "id": despuesCambio.key, "idDispositivo": despuesCambio.idDispositivo, "nombreDispositivo": despuesCambio.nombreDispositivo, "sesionCerrada": false, "fechaRevocacion": 0, "idToken": presenciaFirestore.get("idToken") })
                    return batchEscrituraEstadoConexion.commit().catch((e) => {
                        return notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e.message, "tipo": "actualizarEstadoFirebase" })
                    });

                }


                else {
                    ///La sesion se ha cerrado completamente, se puede observar que el nombre y el idDispositivo estan en blanco, la cuenta esta receptiva a otros dispositivos

                    if (despuesCambio.sesionCerrada === (true as boolean)) {
                        batchEscrituraEstadoConexion.set(statusGeneralFirestoreUsuario, { estaConectado: false, "id": despuesCambio.key, "idDispositivo": "", "nombreDispositivo": "", "sesionCerrada": true, "fechaRevocacion": 0, "idToken": presenciaFirestore.get("idToken") })

                    }

                    ///La sesion no se ha cerrado completamente, se puede observar que el nombre y el idDispositivo estan en blanco, la cuenta esta receptiva a otros dispositivos

                    else {
                        batchEscrituraEstadoConexion.set(statusGeneralFirestoreUsuario, { estaConectado: false, "id": despuesCambio.key, "idDispositivo": despuesCambio.idDispositivo, "nombreDispositivo": despuesCambio.nombreDispositivo, "sesionCerrada": false, "fechaRevocacion": 0, "idToken": presenciaFirestore.get("idToken") })

                    }
                    return batchEscrituraEstadoConexion.commit().catch((e) => {
                        return notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e.message, "tipo": "actualizarEstadoFirebase" })
                    });
                }
            }
            else {
                return null
            }

        }





    }



});

/**
 * Cada vez que el cliente actualice sus immagenes, esta funcion se encarga de replicar ese cambio 
 * en todas las coversaciones,solicitudes de chat y valoraciones
 * 
 */



export const bloqueadorPerfilesAutomatico = functions.firestore.document("expedientes/{expedientesId}").onUpdate(async (change) => {

    var newVersion = change.after;

    var cantidadDenuncias: number = newVersion.get("cantidadDenuncias");
    var batchEscritra = admin.firestore().batch();

    if (cantidadDenuncias > 1) {
        var documentoUsuario = await admin.firestore().collection("usuarios").doc(change.after.id).get();

        var estadoSancionUsuario = documentoUsuario.get("sancionado");

        var usuarioSancionado = estadoSancionUsuario["usuarioSancionado"];

        if (usuarioSancionado === false) {
            batchEscritra.update(admin.firestore().collection("usuarios").doc(documentoUsuario.id), { "sancionado.usuarioSancionado": true })
            batchEscritra.update(admin.firestore().collection("expedientes").doc(documentoUsuario.id), { "sancionado": true })


            return batchEscritra.commit()
                ;
        }
        else {
            return null;
        }

    } else {
        return null;
    }



});



export const actualizarImagenesConversaciones = functions.firestore.document("usuarios/{usuariosId}").onUpdate(async (change) => {

    console.log(change.before.id)

    const idUsuario = change.before.id;
    var imagenActualizada = "vacio";
    var valoresIguales = 0 as number;


    const conversaciones = await iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).collection("conversaciones").get();
    const anterior1 = change.before.get("IMAGENPERFIL1")["Imagen"];
    const anterior2 = change.before.get("IMAGENPERFIL2")["Imagen"];
    const anterior3 = change.before.get("IMAGENPERFIL3")["Imagen"];
    const anterior4 = change.before.get("IMAGENPERFIL4")["Imagen"];
    const anterior5 = change.before.get("IMAGENPERFIL5")["Imagen"];
    const anterior6 = change.before.get("IMAGENPERFIL6")["Imagen"];
    const batchEscrituraValoracioesPrivadas: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();


    const imagenPosterior1 = change.after.get("IMAGENPERFIL1")["Imagen"];
    const imagenPosterior2 = change.after.get("IMAGENPERFIL2")["Imagen"];
    const imagenPosterior3 = change.after.get("IMAGENPERFIL3")["Imagen"];
    const imagenPosterior4 = change.after.get("IMAGENPERFIL4")["Imagen"];
    const imagenPosterior5 = change.after.get("IMAGENPERFIL5")["Imagen"];
    const imagenPosterior6 = change.after.get("IMAGENPERFIL6")["Imagen"];

    var listaValoresAntiguos: any[] = [anterior1, anterior2, anterior3, anterior4, anterior5, anterior6];
    var listaValoresNuevos: any[] = [imagenPosterior1, imagenPosterior2, imagenPosterior3, imagenPosterior4, imagenPosterior5, imagenPosterior6];

    for (var y = 0; y < listaValoresAntiguos.length; y++) {
        if (listaValoresAntiguos[y] === null || listaValoresAntiguos[y] === undefined) {
            listaValoresAntiguos[y] = "vacio";

        }
    }
    for (var x = 0; x < listaValoresNuevos.length; x++) {
        if (listaValoresNuevos[x] === null || listaValoresNuevos[x] === undefined) {
            listaValoresNuevos[x] = "vacio";

        }
    }

    for (let a = 0; a < listaValoresAntiguos.length; a++) {

        for (let b = 0; b < listaValoresNuevos.length; b++) {
            if (listaValoresNuevos[b] === listaValoresAntiguos[a]) {
                valoresIguales++;


            }

        }


    }


    if ((valoresIguales + 1 !== listaValoresNuevos.length)) {

        for (let i = 0; i < listaValoresNuevos.length && imagenActualizada === "vacio"; i++) {


            imagenActualizada = listaValoresNuevos[i];


        }

        if (imagenActualizada !== "vacio" && imagenActualizada) {

            conversaciones.forEach(async (value) => {
                var idRemitente = value.get("idRemitente");
                var idConversacion = value.id;



                batchEscrituraValoracioesPrivadas.update(iniciarFirestore.firestore().collection("usuarios").doc(idRemitente).collection("conversaciones").doc(idConversacion), { "imagenRemitente": imagenActualizada })
            });
            //Aqui hacemos los cambios a las valoraciones

            await iniciarFirestore.firestore().collection("valoracionesPrivadas").where("Time", ">", admin.firestore.Timestamp.now().seconds - 86400).where("Id emisor", "==", idUsuario).get().then(async (valoracionesPrivadas) => {
                valoracionesPrivadas.forEach((valoracionPrivada) => {
                    batchEscrituraValoracioesPrivadas.update(valoracionPrivada.ref, { "Imagen Usuario": imagenActualizada })

                })

                await iniciarFirestore.firestore().collection("valoraciones").where("Id emisor", "==", idUsuario).where("revelada", "==", true).get().then((valoraciones) => {
                    valoraciones.forEach((valoracion) => {
                        batchEscrituraValoracioesPrivadas.update(valoracion.ref, { "Imagen Usuario": imagenActualizada });
                    })
                })

            })

            //Aqui hacemos los cambios a las solicitudes de chat

            await iniciarFirestore.firestore().collection("solicitudesPrivadas").where("tiemmpo", ">", admin.firestore.Timestamp.now().seconds - 86400).where("idEmisor", "==", idUsuario).get().then(async (valoracionesPrivadas) => {
                valoracionesPrivadas.forEach((valoracionPrivada) => {
                    batchEscrituraValoracioesPrivadas.update(valoracionPrivada.ref, { "imagenEmisor": imagenActualizada })

                })

                await iniciarFirestore.firestore().collection("solicitudes").where("idEmisor", "==", idUsuario).where("revelada", "==", true).get().then((valoraciones) => {
                    valoraciones.forEach((valoracion) => {
                        batchEscrituraValoracioesPrivadas.update(valoracion.ref, { "imagenEmisor": imagenActualizada });
                    })
                    batchEscrituraValoracioesPrivadas.update(iniciarFirestore.firestore().collection("expedientes").doc(idUsuario), { "imagenes": listaValoresNuevos, "descripcion": change.after.get("Descripcion") })

                    return batchEscrituraValoracioesPrivadas.commit();

                })


            })
        }

    }
    if ((valoresIguales + 1 === listaValoresNuevos.length)) {
        return null;
    }


    return null;







});












/**
 * Funcion usada para que el usuario solicite sus monedas diarias siempre y cuando haya pasao el tiempo de espera de un dia
 */



export const darCreditosUsuario = functions.https.onCall(async (valor) => {

    const mapa: Record<string, any> = valor;


    const cantidadCreditos: number = mapa["creditos"];

    let creditosUsuarioActuales: number = 0;
    let valorTotalCreditos: number = cantidadCreditos + creditosUsuarioActuales;
    const idUsuario: string = mapa["idUsuario"];

    if (idUsuario)
        await iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).get().then(async (valoresUsuario) => {
            creditosUsuarioActuales = await valoresUsuario.get("creditos");
            valorTotalCreditos = cantidadCreditos + creditosUsuarioActuales;

            await iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({ "creditos": valorTotalCreditos }).catch((error) => {
                return { "estado": "error", "mensaje": "error_dar_creditos_usuario", "tipo": "creditosDiarios" }
            });
        });


    return { "estado": "correcto", "mensaje": "", "tipo": "creditosDiarios" }
})


/**
 * Se quita creditos al usuario al intentar revelar una valoracion, o en caso de que sea premium se revela
 * Si el usuario se va a quedar con menos de 200 creditos enntonces se crea una recopensa que podria ser usada a las 24 h
 */

export const quitarCreditosUsuario = functions.https.onCall(async (valor) => {



    const mapa: Record<string, any> = valor;


    const cantidadCreditos: number = 200;
    const idValoracion: string = mapa["idValoracion"];
    const idUsuario: string = mapa["idUsuario"];
    const primeraInicializacion: boolean = mapa["primeraSolicitud"];
    var escrituraPorLotes = iniciarFirestore.firestore().batch();
    var referenciaValoracion = iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(idValoracion);
    var referenciaValoracionPublica = iniciarFirestore.firestore().collection("valoraciones").doc(idValoracion);
    var datosValoracion = await referenciaValoracion.get();
    const ultimaCompra: number = admin.firestore.Timestamp.now().seconds + 60;

    var referenciaCreditosUsuario = iniciarFirestore.firestore().collection("usuarios").doc(idUsuario);
    var valoracionGuardada: Record<string, any> = {
        "Id emisor": datosValoracion.get("Id emisor"),
        "Imagen Usuario": datosValoracion.get("Imagen Usuario"),
        "Nombe emisor": datosValoracion.get("Nombe emisor"),
        "Time": datosValoracion.get("Time"),
        "Valoracion": datosValoracion.get("Valoracion"),
        "caducidad": (new Date(2100, 5, 0).getTime()) / 1000,
        "hash": datosValoracion.get("hash"),
        "id valoracion": datosValoracion.get("id valoracion"),
        "idDestino": datosValoracion.get("idDestino"),
        "notificada": true,
        "prioridad": datosValoracion.get("prioridad"),
        "revelada": true,
        "visible": true,
        "idTarea": datosValoracion.get("idTarea"),
        "reaccion": datosValoracion.get("reaccion"),
        "bloqueado": datosValoracion.get("bloqueado"),


    }






    if (!primeraInicializacion) {
        return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).get().then(async (valoresUsuario) => {
            const usuarioEsPremium: boolean = valoresUsuario.get("monedasInfinitas");
            if (usuarioEsPremium === false) {
                var creditosUsuarioActuales: number = valoresUsuario.get("creditos");

                if (creditosUsuarioActuales >= (cantidadCreditos)) {

                    var valorTotalCreditos = creditosUsuarioActuales - cantidadCreditos;
                    escrituraPorLotes.update(referenciaCreditosUsuario, { "creditos": valorTotalCreditos });
                    escrituraPorLotes.update(referenciaValoracion, valoracionGuardada);
                    escrituraPorLotes.set(referenciaValoracionPublica, valoracionGuardada);

                    if (valorTotalCreditos < 200) {

                        escrituraPorLotes.update(referenciaCreditosUsuario, {
                            "esperandoRecompensa": true,
                            "siguienteRecompensa": ultimaCompra
                        });


                    }

                    return escrituraPorLotes.commit().then(async () => {
                        await programadorTareaEliminacionValoraciones(idValoracion, 0, true, datosValoracion.get("idTarea"))
                        await ponerNotificacionRecompensaEnEspera(idUsuario, ultimaCompra, true).catch((error) => {
                            notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": error, "tipo": "ponerNotificacionesRecompensaEnEspera" })
                        });

                        return { "estado": "correcto", "mensaje": "", "tipo": "revelar_valoracion" };
                    }).catch(async () => {



                        return { "estado": "error", "mensaje": "creditos_insuficioetes", "tipo": "revelar_valoracion" }

                    })
                }
                else {
                    return { "estado": "error", "mensaje": "creditos_insuficioetes", "tipo": "revelar_valoracion" }
                }

            }
            else {



                escrituraPorLotes.update(referenciaValoracion, valoracionGuardada);
                escrituraPorLotes.set(referenciaValoracionPublica, valoracionGuardada);

                return escrituraPorLotes.commit().then(async () => {
                    await programadorTareaEliminacionValoraciones(idValoracion, 0, true, datosValoracion.get("idTarea"))
                    return { "estado": "correcto", "mensaje": "", "tipo": "revelar_valoracion" };

                }).catch((errorBatch) => {
                    return { "estado": "error", "mensaje": errorBatch, "tipo": "revelar_valoracion" }


                });

            }





        })
    }
    else {

        return null
    }












})
/**
 * Se quita creditos al usuario al intentar revelar una solicitud, o en caso de que sea premium se revela
 * Si el usuario se va a quedar con menos de 200 creditos enntonces se crea una recopensa que podria ser usada a las 24 h
 */

export const quitarCreditosUsuarioSolicitudes = functions.https.onCall(async (valor) => {



    const mapa: Record<string, any> = valor;


    const cantidadCreditos: number = 200;
    const idSolicitud: string = mapa["idSolicitud"];
    const idUsuario: string = mapa["idUsuario"];
    const primeraSolicitud: boolean = mapa["primeraSolicitud"];
    const escrituraPorLotes = iniciarFirestore.firestore().batch();
    const referenciaSolicitud = iniciarFirestore.firestore().collection("solicitudesPrivadas").doc(idSolicitud);
    const referenciaSolicitudesPublicas = iniciarFirestore.firestore().collection("solicitudes").doc(idSolicitud);
    const ultimaCompra: number = admin.firestore.Timestamp.now().seconds + 86400;

    const referenciaCreditosUsuario = iniciarFirestore.firestore().collection("usuarios").doc(idUsuario);
    var datosSolicitud = await referenciaSolicitud.get();
    var solicitudGuardada: Record<string, any> = {
        "idEmisor": datosSolicitud.get("idEmisor"),
        "imagenEmisor": datosSolicitud.get("imagenEmisor"),
        "nombreEmisor": datosSolicitud.get("nombreEmisor"),
        "tiemmpo": datosSolicitud.get("tiemmpo"),
        "caducidad": 0,
        "hash": datosSolicitud.get("hash"),
        "idSolicitudConversacion": datosSolicitud.get("idSolicitudConversacion"),
        "idDestino": datosSolicitud.get("idDestino"),
        "notificada": true,
        "prioridad": datosSolicitud.get("prioridad"),
        "superLike": false,
        "revelada": true,
        "visible": true,
        "idTarea": datosSolicitud.get("idTarea")


    }

    if (!primeraSolicitud) {
        return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).get().then(async (valoresUsuario) => {
            const creditosUsuarioActuales: number = valoresUsuario.get("creditos");
            const esPremium: boolean = valoresUsuario.get("monedasInfinitas");

            if (esPremium === false) {
                if (creditosUsuarioActuales >= (cantidadCreditos)) {

                    var valorFinalCreditosUsuario = creditosUsuarioActuales - cantidadCreditos;
                    escrituraPorLotes.update(referenciaCreditosUsuario, { "creditos": valorFinalCreditosUsuario });
                    escrituraPorLotes.update(referenciaSolicitud, solicitudGuardada);
                    escrituraPorLotes.set(referenciaSolicitudesPublicas, solicitudGuardada);

                    if (valorFinalCreditosUsuario < 200) {

                        escrituraPorLotes.update(referenciaCreditosUsuario, {
                            "esperandoRecompensa": true,
                            "siguienteRecompensa": ultimaCompra
                        });
                        await ponerNotificacionRecompensaEnEspera(idUsuario, ultimaCompra, false).catch((error) => {
                            notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": error, "tipo": "ponerNotificacionesRecompensaEnEspera" })

                        })

                    }
                    return escrituraPorLotes.commit().then(async () => {

                        return { "estado": "correcto", "mensaje": "", "tipo": "revelar_solicitud" };
                    }).catch(async () => {
                        await ponerNotificacionRecompensaEnEspera(idUsuario, ultimaCompra, true).catch((error) => {
                            notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": error, "tipo": "ponerNotificacionesRecompensaEnEspera" })

                        });

                        return { "estado": "error", "mensaje": "creditos_insuficioetes", "tipo": "revelar_dolicitud" }

                    })
                }
                else {
                    return { "estado": "error", "mensaje": "creditos_insuficioetes", "tipo": "revelar_dolicitud" }
                }

            }
            else {
                escrituraPorLotes.update(referenciaSolicitud, solicitudGuardada);
                escrituraPorLotes.set(referenciaSolicitudesPublicas, solicitudGuardada);
                return escrituraPorLotes.commit().then(() => {
                    return { "estado": "correcto", "mensaje": "", "tipo": "revelar_solicitud" }
                }).catch(() => {
                    return { "estado": "error", "mensaje": "error_interno", "tipo": "revelar_solicitud" }
                })


            }






        }).catch(() => {
            return { "estado": "correcto", "mensaje": "", "tipo": "revelar_solicitud" }
        });
    }

    else {
        return "cantidadCreditos";
    }





})

/**
 * Esta funcion solicita la primera recompensa la cual se da cuando el usuario se registra y es unica,
 * Regala 3000 creditos
 */
export const pedirPrimeraRecompensa = functions.https.onCall(async (data, context) => {
    const id: string = context.auth?.uid as string;
    const documentoUsuario = await admin.firestore().collection("usuarios").doc(id).get();
    if (documentoUsuario.exists) {
        var primeraRecompensa = documentoUsuario.get("primeraRecompensa");
        if (primeraRecompensa === true) {
            var escrituraPorLotes = iniciarFirestore.firestore().batch();
            escrituraPorLotes.update(documentoUsuario.ref, { "primeraRecompensa": false });
            escrituraPorLotes.update(documentoUsuario.ref, { "creditos": 30000 });
            await escrituraPorLotes.commit()

            return { "estado": "correcto", "mensaje": "", "tipo": "" }



        }
        else {
            return { "estado": "error", "mensaje": "recomensa _no_disponible", "tipo": "" }

        }
    }
    else {
        return { "estado": "error", "mensaje": "", "tipo": "" }
            ;
    }
})

/**
 * Esta funcion solicita la  recompensa diaria
 * Regala 500 creditos
 */

export const solcitarCreditosDiarios = functions.https.onCall(async (valor, context) => {
    const idUsuarioSolicitante: string = context.auth?.uid as string;


    return iniciarFirestore.firestore().collection("usuarios").doc(idUsuarioSolicitante).get().then(async (valorConsulta) => {

        const valorSiguienteRecompensa: number = valorConsulta.get("siguienteRecompensa");
        if (valorSiguienteRecompensa > 0) {
            const fechaActualSegundos: number = admin.firestore.Timestamp.now().seconds;
            const diferenciaFechas: number = fechaActualSegundos - valorSiguienteRecompensa;
            if (diferenciaFechas > 0 || diferenciaFechas >= -300) {
                const escrituraPorLotes = iniciarFirestore.firestore().batch();
                const referenciaUsuario = iniciarFirestore.firestore().collection("usuarios").doc(idUsuarioSolicitante);
                escrituraPorLotes.update(referenciaUsuario, { "esperandoRecompensa": false, "siguienteRecompensa": 0 });

                escrituraPorLotes.update(referenciaUsuario, { "creditos": admin.firestore.FieldValue.increment(200) });


                return escrituraPorLotes.commit().then(() => {
                    return { "estado": "correcto", "mensaje": "", "tipo": "creditosDiarios" }
                }).catch((error) => {
                    return { "estado": "error", "mensaje": error, "tipo": "creditosDiarios" }
                });



            }
            else {
                return { "estado": "error", "mensaje": "recompensa_no_preparada", "tipo": "creditosDiarios" }

            }
        }
        else {
            return { "estado": "error", "mensaje": "valor_no_valido", "tipo": "creditosDiarios" }

        }


    })



})


export const requestNewVerificationProcess = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    //const kProfileInReviewProcess = "PROFILE_IN_REVIEW_PROCESS";
    //const kProfileReviewedSuccesfully = "PROFILE_REVIEW_SUCCESFULL";
    //const kProfileRefiewedError = "PROFILE_REVIEW_ERROR";
    if (context.auth != null) {
        try {
            const userId: string = context.auth.uid;
            var userHasVerificationAttempt: boolean = await (await admin.firestore().collection("verificationDataCollection").doc(userId).get()).exists
            const handGestures: string[] = ["thumbs_up_gesture", "victory_gesture", "thumbs_down_gesture", "raised_hand_gesture", "pinching_hand_gesture", "ok_gesture", "raised_punch_gesture",]
            var randomNumber: number = Math.floor(Math.random() * 7);
            var handGesture: string = handGestures[randomNumber];
            var verificationTicketId: string = idAleatorio();
            if (userHasVerificationAttempt === true) {
                await admin.firestore().collection("verificationDataCollection").doc(userId).set({ "handGesture": handGesture, "verified": false, "verificationAttempts": admin.firestore.FieldValue.increment(1), "status": kProfileNotReviewed, "verificationTicketId": verificationTicketId, "female": true, "image": "" })
                return { "estado": "correcto", "mensaje": "_" };


            }
            else {
                await admin.firestore().collection("verificationDataCollection").doc(userId).set({ "handGesture": handGesture, "verified": false, "verificationAttempts": 0, "status": kProfileNotReviewed, "verificationTicketId": verificationTicketId, "female": true, "image": "" })
                return { "estado": "correcto", "mensaje": "_" };

            }

        } catch (e) {

            return notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e, "funcion": "requestNewVerificationProcess" })

        }
    } else {
        return { "estado": "error", "mensaje": "usuario_no_autenticado" };

    }



})




export const enviarSolicitudVerificacion = functions.https.onCall(async (valor) => {

    const datosVerificacion: Record<string, any> = valor;
    const imagenesPerfil: string[] = datosVerificacion["imagenesPerfil"];
    const imagenObjetivo: string = datosVerificacion["obejtivo"];
    const imagenParaVerificar: string = datosVerificacion["imagen"];
    const idSolicitante: string = datosVerificacion["idSolicitante"];
    const idSolicitud: string = datosVerificacion["idSolicitud"];
    const referenciaUsuario: FirebaseFirestore.DocumentReference = iniciarFirestore.firestore().collection("usuarios").doc(idSolicitante);
    const referenciaVerificacion: FirebaseFirestore.DocumentReference = iniciarFirestore.firestore().collection("solicitudesVerificacion").doc(idSolicitud);
    let batchEscritra: FirebaseFirestore.WriteBatch = iniciarFirestore.firestore().batch();
    return iniciarFirestore.firestore().collection("usuarios").doc(idSolicitante).get().then((dato) => {
        const verificado: Record<string, any> = dato.get("verificado");
        const verificacionPalabra: string = verificado["estadoVerificacion"];
        if (verificacionPalabra === "verificado") {


            return null;
        }

        else {
            batchEscritra.update(referenciaUsuario, { "verificado": { "estadoVerificacion": "enProceso", "verificacionNotificada": false } });
            batchEscritra.set(referenciaVerificacion, {
                "Fase1": {
                    "imagen": imagenParaVerificar, "obejtivo": imagenObjetivo
                },

                "aprobada": false,
                "fecha": admin.firestore.Timestamp.now(),
                "procesada": false,
                "imagenesPerfil": imagenesPerfil


            })

            return batchEscritra.commit();



        }
    })


})













export const verificarCompraGoogle = functions.https.onCall(async (tokenCompra) => {


    const purchaseToken: string = tokenCompra["tokenCompra"]
    const nombrePaquete: string = tokenCompra["nombrePaquete"]
    const idUsuario: string = tokenCompra["idUsuario"]
    const referenciaUsuarioDestino = iniciarFirestore.firestore().collection("usuarios").doc(idUsuario);
    const idProducto: string = tokenCompra["idProducto"];
    var cantidadMonedas: number = 0;
    var estadoCompra = "desconocido";
    console.log(idProducto);
    console.log(nombrePaquete);
    console.log(purchaseToken)
    console.log(idUsuario);
    if (idProducto === "1000creditos") {
        cantidadMonedas = 1000;
    }
    if (idProducto === "2000creditos") {
        cantidadMonedas = 2000;
    }
    if (idProducto === "3500creditos") {
        cantidadMonedas = 3500;
    }



    try {
        await authClient.authorize();
        const compra = await playDeveloperApiClient.purchases.products.get({
            packageName: nombrePaquete,
            productId: idProducto,
            token: purchaseToken,
        });

        if (compra.status === 200) {


            return iniciarFirestore.firestore().runTransaction(async (valor) => {
                return valor.get(referenciaUsuarioDestino).then(async () => {
                    await valor.update(referenciaUsuarioDestino, { "creditos": admin.firestore.FieldValue.increment(cantidadMonedas) })
                    if (compra.data.purchaseState === 0) {
                        estadoCompra = "comprado"
                    }
                    if (compra.data.purchaseState === 1) {
                        estadoCompra = "cancelado"
                    }
                    if (compra.data.purchaseState === 2) {
                        estadoCompra = "pendiente"
                    }


                    return iniciarFirestore.firestore().collection("ticketsCompras").doc(purchaseToken).set({ "usuario": compra.data.obfuscatedExternalAccountId, "fechaCompra": compra.data.purchaseTimeMillis, "estadoPago": estadoCompra, "tokenCompra": compra.data.purchaseToken })


                })

            })

        }
        else {
            return "noVerificado"
        }
    }

    catch (error) {

        console.log(error)
        return error

    }


});


const authClient = new google.auth.JWT({
    email: claveGoogle.client_email,
    key: claveGoogle.private_key,
    scopes: ["https://www.googleapis.com/auth/androidpublisher"]
});




const playDeveloperApiClient = google.androidpublisher({
    version: 'v3',
    auth: authClient

});

export const comprobadorSuscripcionesGooglePlay = functions.https.onCall(async (data) => {
    var esPremium = false;
    var tokenEnlazado: any = "";
    var caducidad: any = 0;
    var estadoPago: string = "";
    var enPausa: boolean = false;
    var periodoDeGracia: boolean = false;





    let tokenCompra: string;



    tokenCompra = data["tokenCompra"];

    const idSuscripcion: string = data["idSuscripcion"];
    const idUsuario: string = data["idUsuario"];




    console.log(tokenCompra);
    // 10 Suscripcion pausada
    // 13 Suscripcion caducada
    // 12 Suscripcion revocada
    //En estos casos la suscripción seria cancelada y el privilegio que esta concede (monedas infinitas)
    //se perderá



    // 01 Suscripcion reactivada (ACCESO:TRUE)
    // 02 Suscripcion activa renovada (puede estar activa pero no renovarse si el usuario lo decide)
    // 03 Suscripcion cancelada

    // 04 Suscripcion comprada
    // 07 Suscripcion reiniciada (el usuario debe asi dejarlo constante desde su tienda Google play)
    //En estos casos os privilegios que conllevan la suscripcion seran concedidos al usuario




    await authClient.authorize();
    const compra = await playDeveloperApiClient.purchases.subscriptions.get({
        packageName: "com.hotty.citas",
        subscriptionId: idSuscripcion,
        token: tokenCompra,

    });

    if (compra.data.acknowledgementState === 0) {
        await playDeveloperApiClient.purchases.subscriptions.acknowledge(
            {
                packageName: "com.hotty.citas",
                subscriptionId: idSuscripcion,
                token: tokenCompra,

            }
        )
    }
    if (compra.data.paymentState !== null && compra.data.paymentState !== undefined) {
        if (compra.data.paymentState == 0) {
            //Pago pendiente
            estadoPago = "pagoPendiente";


        }
        if (compra.data.paymentState == 1) {
            //Pago pendiente
            estadoPago = "pagoAceptado";


        }
        if (compra.data.paymentState == 3) {
            //Pago pendiente
            estadoPago = "pagoEnProrrateo";


        }


    }
    else {
        estadoPago = "pagoCancelado";


    }



    if (compra.data.linkedPurchaseToken !== null && compra.data.linkedPurchaseToken !== undefined) {
        tokenEnlazado = compra.data.linkedPurchaseToken;
        caducidad = compra.data.expiryTimeMillis;
        if (caducidad > Date.now()) {
            esPremium = true;

        }
        else {
            esPremium = false;
        }
        console.log(`${tokenEnlazado} token enlazado con`)
        console.log(`${tokenCompra} token compra`)



        await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).set({
            "usuario": idUsuario,
            "fechaExpiracion": compra.data.expiryTimeMillis,
            "estadoPago": estadoPago, "tokenCompra": tokenCompra, "ticketValido": true,
            "ticketEnlazado": tokenEnlazado, "tipoSuscripcion": idSuscripcion,
            "otorgaPrivilegios": esPremium, "periodoGracia": periodoDeGracia,
        })
        await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenEnlazado).update({ "ticketValido": false, "otorgaPrivilegios": false });
        return iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).get().then(async (valor) => {

            const idUsuario: string = valor.get("usuario");
            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                "monedasInfinitas": esPremium, "ticketSuscripcion": tokenCompra,
                "idSuscripcion": idSuscripcion, "estadoPagoSuscripcion": estadoPago, "suscripcionEnPausa": enPausa,
                "caducidadSuscripcion": caducidad
            })
        })
    }
    else {
        tokenEnlazado = "";
        caducidad = compra.data.expiryTimeMillis;
        if (caducidad > Date.now()) {
            esPremium = true;

        }
        else {
            esPremium = false;
        }
        console.log(`${tokenEnlazado} token enlazado sin`)
        console.log(`${tokenCompra} token compra`)



        await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).set({
            "usuario": idUsuario,
            "fechaExpiracion": compra.data.expiryTimeMillis,
            "estadoPago": estadoPago, "tokenCompra": tokenCompra, "ticketValido": true,
            "ticketEnlazado": tokenEnlazado, "tipoSuscripcion": idSuscripcion,
            "otorgaPrivilegios": esPremium, "periodoGracia": periodoDeGracia,
        })
        return iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).get().then(async (valor) => {

            const idUsuario: string = valor.get("usuario");
            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                "monedasInfinitas": esPremium,
                "ticketSuscripcion": tokenCompra, "idSuscripcion": idSuscripcion,
                "estadoPagoSuscripcion": estadoPago, "suscripcionEnPausa": enPausa, "caducidadSuscripcion": caducidad
            })
        })
    }










})



/**
 * 
 * Escuchador de compras de suscripciones en google play
 */


export const revenueCatSubscriptions = functions.https.onRequest(async (req, res) => {

    const data = req.body;
    const userId: string | null = data["event"]["app_user_id"];
    const productId: string | null = data["event"]["product_id"];
    const eventExpirationTime: number | null = data["event"]["expiration_at_ms"];
    const eventType: string | null = data["event"]["type"];



    var premium: boolean = false;
    //var subscriptionState="";
    const subscriptionActive = "ACTIVA";
    const subscriptionCacelled = "CANCELADA";
    const subscriptionBillingProblem = "PROBLEMA_PAGO";
    const notSubscribed = "NO_SUSCRITO";



    if (eventExpirationTime != null) {
        if (eventExpirationTime > Date.now()) {
            premium = true;
        }

    }



    ///Primera compra

    console.log(eventType);

    if (eventType === "INITIAL_PURCHASE") {
        console.log("paso1")

        console.log("paso1")



        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionActive, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })





    }
    /// Renovada (puede ser renovada automaticamente cuando llega la fecha de renovacion o si se suscribe en periodo de gracia)
    if (eventType === "RENEWAL") {
        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionActive, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })



    }
    /*El usuario cambia su suscripcion
    if (eventType === "PRODUCT_CHANGE") {
        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionActive, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })


    }*/
    /// suscripcion cancelada
    if (eventType === "CANCELLATION") {
        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionCacelled, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })




    }
    ///se vueelve a suscribir tras cancelar la suscripcion
    if (eventType === "UNCANCELLATION") {

        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionActive, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })



    }
    ///Probleam con el pago (puede que el pago no se haya podido procesar), no implica que la suscripcionn ha caducado
    if (eventType === "BILLING_ISSUE") {
        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": productId,
            "estadoPagoSuscripcion": subscriptionBillingProblem, "suscripcionEnPausa": false, "caducidadSuscripcion": eventExpirationTime, "finPausaSuscripcion": 0

        })


    }

    /// Caducada, en caso de que el usuario haya cancelado la suscripcion y aun tenga acceso
    ///cuando este deje de tener acceso por caducidad se emitira este evento
    if (eventType === "EXPIRATION") {



        await iniciarFirestore.firestore().collection("usuarios").doc(userId as string).update({
            "monedasInfinitas": premium,
            "ticketSuscripcion": "tokenCompra", "idSuscripcion": "",
            "estadoPagoSuscripcion": notSubscribed, "suscripcionEnPausa": false, "caducidadSuscripcion": 0,
            "finPausaSuscripcion": 0

        })





    }



    res.sendStatus(200);


    return




})


export const escuchadorSuscripcionesYcomprasLentasGooglePlay = functions.pubsub.topic("suscripcionesHotty").onPublish(async (data) => {
    const datosEnBase64: string = data.data;
    const jsonDatosSuscripcion: any = JSON.parse(Buffer.from(datosEnBase64, "base64").toString());
    const notificacionDesarollador = jsonDatosSuscripcion;
    var esPremium = false;
    var tokenEnlazado: any = "";
    var caducidad: any = 0;
    var estadoPago: string = "";
    var enPausa: boolean = false;
    var periodoDeGracia: boolean = false;
    var tiketEsValido: boolean = true;
    var razonCancelacion: string = "";



    if (notificacionDesarollador["subscriptionNotification"] !== undefined) {
        let tokenCompra: string;

        let notificacionSuscripcion: number;


        notificacionSuscripcion = notificacionDesarollador["subscriptionNotification"]["notificationType"] as number;
        tokenCompra = notificacionDesarollador["subscriptionNotification"]["purchaseToken"];

        const idSuscripcion: string = notificacionDesarollador["subscriptionNotification"]["subscriptionId"];




        console.log(tokenCompra);
        console.log(notificacionSuscripcion);
        // 10 Suscripcion pausada
        // 13 Suscripcion caducada
        // 12 Suscripcion revocada
        //En estos casos la suscripción seria cancelada y el privilegio que esta concede (monedas infinitas)
        //se perderá



        // 01 Suscripcion reactivada (ACCESO:TRUE)
        // 02 Suscripcion activa renovada (puede estar activa pero no renovarse si el usuario lo decide)
        // 03 Suscripcion cancelada

        // 04 Suscripcion comprada
        // 07 Suscripcion reiniciada (el usuario debe asi dejarlo constante desde su tienda Google play)
        //En estos casos os privilegios que conllevan la suscripcion seran concedidos al usuario

        if (notificacionSuscripcion !== 4) {

            await authClient.authorize();
            const compra = await playDeveloperApiClient.purchases.subscriptions.get({
                packageName: "com.hotty.citas",
                subscriptionId: idSuscripcion,
                token: tokenCompra,

            });

            if (compra.data.acknowledgementState === 0) {
                await playDeveloperApiClient.purchases.subscriptions.acknowledge(
                    {
                        packageName: "com.hotty.citas",
                        subscriptionId: idSuscripcion,
                        token: tokenCompra,

                    }
                )
            }
            if (compra.data.paymentState !== null && compra.data.paymentState !== undefined) {
                if (compra.data.paymentState == 0) {
                    //Pago pendiente
                    estadoPago = "pagoPendiente";


                }
                if (compra.data.paymentState == 1) {
                    //Pago pendiente
                    estadoPago = "pagoAceptado";


                }
                if (compra.data.paymentState == 3) {
                    //Pago pendiente
                    estadoPago = "pagoEnProrrateo";


                }


            }
            else {
                estadoPago = "pagoCancelado";


            }



            if (notificacionSuscripcion === 10) {
                //Suscripcion pausada
                enPausa = true;

            }
            if (notificacionSuscripcion === 6) {
                // Suscripcion en periodo de gracia
                periodoDeGracia = true;
            }
            if (notificacionSuscripcion === 13) {
                // Suscripcion en periodo de gracia
                tiketEsValido = false;
            }
            if (compra.data.cancelReason !== null && compra.data.cancelReason !== undefined) {

                if (compra.data.cancelReason === 0) {
                    razonCancelacion = "cancelado_por_usuario";

                }
                if (compra.data.cancelReason === 1) {
                    razonCancelacion = "cancelado_por_sistema";

                }
                if (compra.data.cancelReason === 2) {
                    razonCancelacion = "cancelado_por_remplazo";

                }
                if (compra.data.cancelReason === 3) {
                    razonCancelacion = "cancelado_por_desarollador";

                }

            }




            /// Si el usuario hace alguna actualizacion de la suscripcion generariamos un nuevo ticket de compra, entonces el antiguo ticket de compra deberia invalidarse ya que aunque exista un nuevo ticket por la actualizacion de la suscripcion
            /// el anterior no ha caducado, el linked purchase token nos indica que tiken ya no debe dar privilegios

            if (compra.data.linkedPurchaseToken !== null && compra.data.linkedPurchaseToken !== undefined) {
                tokenEnlazado = compra.data.linkedPurchaseToken;
                caducidad = compra.data.expiryTimeMillis;

                if (caducidad > Date.now()) {
                    esPremium = true;

                }

                else {
                    esPremium = false;
                }
                console.log(`${tokenEnlazado} token enlazado con`)
                console.log(`${tokenCompra} token compra`)


                var documentoTicketAnterior = await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenEnlazado).get();
                var idUsuarioDocumentoEnlazado = documentoTicketAnterior.get("usuario");



                await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).set({
                    "usuario": idUsuarioDocumentoEnlazado, "fechaExpiracion": compra.data.expiryTimeMillis,
                    "estadoPago": estadoPago, "tokenCompra": tokenCompra, "ticketValido": tiketEsValido, "ticketEnlazado": tokenEnlazado, "tipoSuscripcion": idSuscripcion,
                    "otorgaPrivilegios": esPremium, "periodoGracia": periodoDeGracia, "suscripcionEnPausa": enPausa,
                })
                await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenEnlazado).update({ "ticketValido": false, "otorgaPrivilegios": false, "suscripcionEnPausa": enPausa, });
                return iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).get().then(async (valor) => {

                    const idUsuario: string = valor.get("usuario");
                    console.log(`Razon de cancelacion ${razonCancelacion} `)



                    if (razonCancelacion !== "cancelado_por_remplazo") {

                        if (razonCancelacion !== "") {
                            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                                "monedasInfinitas": esPremium, "ticketSuscripcion": "",
                                "idSuscripcion": "", "estadoPagoSuscripcion": "", "suscripcionEnPausa": enPausa,
                                "caducidadSuscripcion": caducidad, "periodoGracia": periodoDeGracia,
                            })


                        }
                        else {

                            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                                "monedasInfinitas": esPremium, "ticketSuscripcion": tokenCompra,
                                "idSuscripcion": idSuscripcion, "estadoPagoSuscripcion": estadoPago, "suscripcionEnPausa": enPausa,
                                "caducidadSuscripcion": caducidad, "periodoGracia": periodoDeGracia,
                            })
                        }


                    }
                    else {
                        return null

                    }

                })
            }
            if (compra.data.linkedPurchaseToken === null || compra.data.linkedPurchaseToken === undefined) {
                tokenEnlazado = "";
                caducidad = compra.data.expiryTimeMillis;
                if (caducidad > Date.now()) {
                    esPremium = true;

                }
                else {
                    esPremium = false;
                }


                console.log(`${tokenEnlazado} token enlazado sin`)
                console.log(`${tokenCompra} token compra`)




                await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).update({
                    "usuario": idUsuarioDocumentoEnlazado, "fechaExpiracion": compra.data.expiryTimeMillis,
                    "estadoPago": estadoPago, "tokenCompra": tokenCompra, "ticketValido": tiketEsValido, "ticketEnlazado": tokenEnlazado, "tipoSuscripcion": idSuscripcion,
                    "otorgaPrivilegios": esPremium, "periodoGracia": periodoDeGracia, "suscripcionEnPausa": enPausa,
                })
                return iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).get().then(async (valor) => {

                    const idUsuario: string = valor.get("usuario");
                    console.log(`Razon de cancelacion ${razonCancelacion} `)

                    if (razonCancelacion !== "cancelado_por_remplazo") {

                        if (razonCancelacion !== "") {
                            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                                "monedasInfinitas": esPremium, "ticketSuscripcion": "",
                                "idSuscripcion": "", "estadoPagoSuscripcion": "", "suscripcionEnPausa": enPausa,
                                "caducidadSuscripcion": caducidad, "periodoGracia": periodoDeGracia,
                            })


                        }
                        else {

                            return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({
                                "monedasInfinitas": esPremium, "ticketSuscripcion": tokenCompra,
                                "idSuscripcion": idSuscripcion, "estadoPagoSuscripcion": estadoPago, "suscripcionEnPausa": enPausa,
                                "caducidadSuscripcion": caducidad, "periodoGracia": periodoDeGracia,
                            })
                        }


                    }
                    else {
                        return null
                    }
                })
            }

        }







    }


    return null


})

/**
 * Comprobamos si una suscripcion sigue activa antes de decidir si actualizarla o iniciar el proceso de una nueva suscripcion
 * 
 * 
 */

export const comprobarManualmeteSuscripcionesGooglePlay = functions.https.onCall(async (data) => {

    const tokenCompra = data["tokenCompra"];
    const idSuscripcion = data["idSuscripcion"];

    try {
        await authClient.authorize();
        const compra = await playDeveloperApiClient.purchases.subscriptions.get({
            packageName: "com.hotty.citas",
            subscriptionId: idSuscripcion,
            token: tokenCompra,

        });

        if (compra.data.cancelReason === null || compra.data.cancelReason === undefined) {
            return {
                "estado": "correcto", "mensaje": "suscripcion_verificada", "cancelada": false, "caducidad": compra.data.expiryTimeMillis,
            }
        }
        else {
            return {
                "estado": "correcto", "mensaje": "suscripcion_verificada", "cancelada": true, "caducidad": compra.data.expiryTimeMillis,
            }
        }

    } catch (e) {
        return {
            "estado": "correcto", "mensaje": "suscripcion_no_verificada", "cancelada": null, "caducidad": null,
        }
    }





})


export const comprobadorTitularidadSuscripcionGooglePlay = functions.https.onCall(async (data) => {
    const idUsuarioSolicitante = data["idUsuario"];
    const emailSolicitante = data["email"];
    const tokenCompra = data["tokenCompra"];
    try {
        var documentoTicektSuscripcion = await iniciarFirestore.firestore().collection("ticketsSuscripcionesGooglePlay").doc(tokenCompra).get();
        var idUsuarioTitular = documentoTicektSuscripcion.get("usuario");
        var documentoUsuarioTitular = await iniciarFirestore.firestore().collection("usuarios").doc(idUsuarioTitular).get();

        var emailTitular = documentoUsuarioTitular.get("email");

        var propiedadSolicitante: boolean = false;
        if (emailTitular === emailSolicitante && idUsuarioTitular === idUsuarioSolicitante) {
            propiedadSolicitante = true;
        }
        else {
            propiedadSolicitante = false;
        }

        return {
            "estado": "correcto", "mensaje": "titularidaad_verificada", "propiedad_solicitante": propiedadSolicitante, "email_titular": emailTitular,
        }

    }
    catch {
        return {
            "estado": "error", "mensaje": "titularidaad_no_verificada",
        }

    }
})


export const enviarDenuncia = functions.https.onCall(async (data) => {
    const idDenunciado = data["idDenunciado"];
    const idDenunciante = data["idDenunciante"];
    const detallesDenuncia = data["detalles"];
    const convresacionIncluida: boolean = data["conversacionIncluida"];
    const idConversacion = data["idConversacion"]
    var batchEscritura: admin.firestore.WriteBatch = admin.firestore().batch();

    if (convresacionIncluida === false) {
        await admin.firestore().collection("expedientes").doc(idDenunciado).update({
            "cantidadDenuncias": admin.firestore.FieldValue.increment(1),
            "denuncias": admin.firestore.FieldValue.arrayUnion(
                {
                    "vistoModerador": false,
                    "idDenuncia": idAleatorio(),
                    "idDenunciante": idDenunciante,
                    "detallesDenuncia": detallesDenuncia,
                    "horaDenuncia": admin.firestore.Timestamp.now(),
                    "conversacionIncluida": false,
                    "idConversacion": 0

                }

            )
        })
        return { "estado": "correcto", "mensaje": 0 }

    }
    else {

        var mensajesConversacion = await admin.firestore().collection("mensajes").where("idConversacion", "==", idConversacion).get();

        if (mensajesConversacion.docs.length > 0) {
            for (var i = 0; i < mensajesConversacion.docs.length; i++) {
                batchEscritura.set(admin.firestore().collection("mensajesModeracion").doc(mensajesConversacion.docs[i].id), mensajesConversacion.docs[i].data()
                )

                if (i > 400) {
                    await batchEscritura.commit();
                    batchEscritura = admin.firestore().batch();
                }

            }
            await batchEscritura.commit();
            await admin.firestore().collection("expedientes").doc(idDenunciado).update({
                "cantidadDenuncias": admin.firestore.FieldValue.increment(1),
                "denuncias": admin.firestore.FieldValue.arrayUnion(
                    {
                        "vistoModerador": false,
                        "idDenuncia": idAleatorio(),
                        "idDenunciante": idDenunciante,
                        "detallesDenuncia": detallesDenuncia,
                        "horaDenuncia": admin.firestore.Timestamp.now(),
                        "conversacionIncluida": true,
                        "idConversacion": idConversacion

                    }

                )
            })
            return { "estado": "correcto", "mensaje": 0 }

        }
        else {
            return { "estado": "error", "mensaje": "conversacion_sin_mensajes" }

        }



    }


})


/**
 * Funcion llamada desde el cliente para crear nuevas valoraciones
 * 
 * 
 * 
 * 
 */

export const sendMessageNotification = functions.firestore.document("mensajes/{mensajesId}").onCreate(async (data) => {

    const userToNotify: string | null = data.get("notificarEsteUsuario");
    if (userToNotify !== null) {

        var userDocument = await iniciarFirestore.firestore().collection("usuarios").doc(userToNotify).get();

        var userToken: string = userDocument.get("tokenNotificacion");

        if (userToken !== null && userToken.length > 5) {
            console.log("REACTION_NOTIFICATION")
            console.log(userToken);
            await iniciarFirestore.messaging().sendToDevice(userToken, { data: { tipoNotificacion: "mensaje" } }, { priority: "high", contentAvailable: true }).then((value: admin.messaging.MessagingDevicesResponse) => {
                console.log(value.results[0].error);
            }).catch((error) => {
                console.log(error);

            })
            return { "estado": "correcto", "mensaje": "no_match" };
        }
        else {
            return null;

        }
    }
    else {
        return null;

    }


});




async function comprobarSiReaccionExiste(idUsuario: string, idDestino: string, marcaTiempo: number): Promise<boolean> {
    var existeReaccion: boolean = false;

    var documentoParaComprobarSiExisteValoracion = await iniciarFirestore.firestore().collection("valoracionesPrivadas").where("caducidad", ">", marcaTiempo).where("Id emisor", "==", idUsuario).where("idDestino", "==", idDestino).get();
    var documentoParaComprobarSiExisteValoracion2 = await iniciarFirestore.firestore().collection("valoracionesPrivadas").where("caducidad", ">", marcaTiempo).where("Id emisor", "==", idDestino).where("idDestino", "==", idUsuario).get();

    var listaValoraciones: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>[] = [];
    if (documentoParaComprobarSiExisteValoracion.docs.length > 0) {
        listaValoraciones = listaValoraciones.concat(documentoParaComprobarSiExisteValoracion.docs);
    }
    if (documentoParaComprobarSiExisteValoracion2.docs.length > 0) {
        listaValoraciones = listaValoraciones.concat(documentoParaComprobarSiExisteValoracion2.docs);
    }
    listaValoraciones.forEach((dato) => {
        existeReaccion = true;

    });
    return existeReaccion;

}




export const darValoraciones = functions.https.onCall(async (data) => {
    const idDestino: string = data["idDestino"];
    const imagenEmisor: string = data["imagenEmisor"];
    const nombreEmisor: string = data["nombreEmisor"];
    const reaccion: string = data["reaccion"];
    const valoracion: number = data["valoracion"];

    const idEmisor: string = data["idEmisor"]
    const hashImagen: string = data["hash"];
    const idValoracion = idAleatorio();
    const marcaTiempo: number = admin.firestore.Timestamp.now().seconds;
    const caducidadValoracion: number = marcaTiempo + 84600;
    const batchValoraciones: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();
    const referenciaUsuarioDestinatario = admin.firestore().collection("usuarios").doc(idDestino);
    const referenciaValoracionesPrivadas = iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(idValoracion);
    const referenciaValoracionesPublicas = iniciarFirestore.firestore().collection("valoraciones").doc(idValoracion);
    const referenciaHistorialValoraciones = iniciarFirestore.firestore().collection("usuarios").doc(idEmisor).collection("historialValoraciones").doc(idDestino);
    var existeReaccion = await comprobarSiReaccionExiste(idEmisor, idDestino, marcaTiempo);
    existeReaccion = false;



    if (existeReaccion == false) {
        var tokeNotificacion: string;



        await iniciarFirestore.firestore().collection("usuarios").doc(idDestino).get().then((datoToken) => {
            tokeNotificacion = datoToken.get("tokenNotificacion")
        })



        // batchValoraciones.update(iniciarFirestore.firestore().collection("usuarios").doc(idEmisor).collection("puntosCalificaciones").doc("puntosCalificacionesParaDar"),)
        var datosTarea = await programadorTareaEliminacionValoraciones(idValoracion, caducidadValoracion + 60, false, "").catch((error) => {
            notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": error, "tipo": "programadorTareaEliminacionValoraciones" })

        });



        batchValoraciones.create(referenciaValoracionesPrivadas, {
            "Id emisor": idEmisor, "Imagen Usuario": imagenEmisor, "Nombe emisor": nombreEmisor,
            "prioridad": 0,
            "hash": hashImagen,
            "reaccion": reaccion,
            "idDestino": idDestino,
            "valoracion": valoracion,
            "bloqueado": false,
            "Time": marcaTiempo, "Valoracion": valoracion, "caducidad": caducidadValoracion, "id valoracion": idValoracion, "revelada": false, visible: true, "notificada": false, "idTarea": datosTarea

        });
        batchValoraciones.create(referenciaValoracionesPublicas, {

            "idDestino": idDestino,
            "idEmisor": idEmisor, "reaccion": reaccion,
            "prioridad": 0,
            "bloqueado": false,

            "Time": marcaTiempo, "caducidad": caducidadValoracion, "id valoracion": idValoracion, "revelada": false, visible: true, "notificada": false, "idTarea": datosTarea

        });
        batchValoraciones.set(referenciaHistorialValoraciones, {

            "idPerfilHistorial": idDestino,

            "Time": marcaTiempo, "caducidad": caducidadValoracion,

        });




        return batchValoraciones.commit().then(async (_) => {

            await admin.firestore().runTransaction(async (t) => {
                var documentoUsuarioDestino = await t.get(referenciaUsuarioDestinatario);
                var puntuacionTotal = documentoUsuarioDestino.get("puntuacionTotal");
                var cantidadValoracioes = documentoUsuarioDestino.get("cantidadValoraciones");




                if (cantidadValoracioes < 100) {
                    cantidadValoracioes = cantidadValoracioes + 1;
                    puntuacionTotal = puntuacionTotal + valoracion;
                    var mediaTotal = puntuacionTotal / cantidadValoracioes;
                    await t.update(referenciaUsuarioDestinatario, { "puntuacionTotal": admin.firestore.FieldValue.increment(valoracion), "mediaTotal": mediaTotal, "cantidadValoraciones": admin.firestore.FieldValue.increment(1), "ultimaValoracion": admin.firestore.Timestamp.now().toMillis() })


                }
                else {
                    await t.update(referenciaUsuarioDestinatario, { "puntuacionTotal": valoracion, "mediaTotal": valoracion, "cantidadValoraciones": 1, "ultimaValoracion": admin.firestore.Timestamp.now().toMillis() })


                }

            })

            if (tokeNotificacion !== null && tokeNotificacion.length > 5) {
                console.log("REACTION_NOTIFICATION")
                console.log(tokeNotificacion);
                await iniciarFirestore.messaging().sendToDevice(tokeNotificacion, { data: { tipoNotificacion: "valoracion" } }, { priority: "high", contentAvailable: true }).then((value: admin.messaging.MessagingDevicesResponse) => {
                    console.log(value.results[0].error);
                }).catch((error) => {
                    console.log(error);

                })
                return { "estado": "correcto", "mensaje": "OK" };
            }
            else {
                return null;
            }

        }).catch((error) => {
            notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": error, "tipo": "darValoraciones" })

            return { "estado": "error", "mensaje": "error_valoraciones", }

        });





    }
    else {
        return null

    }












})







export const eliminarConversaciones = functions.runWith({ memory: "2GB", "timeoutSeconds": 300 }).https.onCall(async (data) => {
    const idInterlocutor1: string = data["idInterlocutor1"];
    const idInterlocutor2: string = data["idInterlocutor2"];
    const idConversacion: string = data["idConversacion"];
    const denuncia: string = data["detalles"];
    const bloquearUsuario: boolean = true;
    const referenciaInterlocutor1: admin.firestore.DocumentReference = iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor1).collection("conversaciones").doc(idConversacion);
    const referenciaInterlocutor2: admin.firestore.DocumentReference = iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor2).collection("conversaciones").doc(idConversacion);
    const referenciaUsuarioInterlocutor2: admin.firestore.DocumentReference = iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor2);
    const referenciaUsuarioInterlocutor1: admin.firestore.DocumentReference = iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor1);
    var batchEscritura: admin.firestore.WriteBatch = admin.firestore().batch();
    var batchEscritura2: admin.firestore.WriteBatch = admin.firestore().batch();

    var batchEliminacionMensajes: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();

    if (bloquearUsuario === true) {
        batchEliminacionMensajes.delete(referenciaInterlocutor1);
        batchEliminacionMensajes.delete(referenciaInterlocutor2);
        batchEliminacionMensajes.update(referenciaUsuarioInterlocutor1, { "bloqueados": admin.firestore.FieldValue.arrayUnion(idInterlocutor2) })
        batchEliminacionMensajes.update(referenciaUsuarioInterlocutor2, { "bloqueados": admin.firestore.FieldValue.arrayUnion(idInterlocutor1) })

    }

    else {
        batchEliminacionMensajes.delete(referenciaInterlocutor1);
        batchEliminacionMensajes.delete(referenciaInterlocutor2);


    }
    try {


        if (denuncia === "NOT_AVAILABLE") {

            var mensajesConversacion = await admin.firestore().collection("mensajes").where("idConversacion", "==", idConversacion).get();

            var count2 = 0;
            for (var i = 0; i < mensajesConversacion.docs.length; i++) {
                batchEscritura2.delete(admin.firestore().collection("mensajes").doc(mensajesConversacion.docs[i].id)
                )
                count2 = count2 + 1;

                if (count2 > 400) {
                    await batchEscritura2.commit();
                    batchEscritura2 = admin.firestore().batch();
                    count2 = 0;
                }

            }
            await batchEscritura2.commit();
            await batchEliminacionMensajes.commit();

        }
        else {
            var mensajesConversacion = await admin.firestore().collection("mensajes").where("idConversacion", "==", idConversacion).get();

            if (mensajesConversacion.docs.length > 0) {
                var count = 0;
                for (var i = 0; i < mensajesConversacion.docs.length; i++) {
                    batchEscritura.set(admin.firestore().collection("mensajesModeracion").doc(mensajesConversacion.docs[i].id), mensajesConversacion.docs[i].data()
                    )
                    count = count + 1;

                    if (count > 400) {
                        await batchEscritura.commit();
                        batchEscritura = admin.firestore().batch();
                        count = 0;
                    }

                }
                await batchEscritura.commit();
                await admin.firestore().collection("expedientes").doc(idInterlocutor2).update({
                    "cantidadDenuncias": admin.firestore.FieldValue.increment(1),
                    "denuncias": admin.firestore.FieldValue.arrayUnion(
                        {
                            "vistoModerador": false,
                            "idDenuncia": idAleatorio(),
                            "idDenunciante": idInterlocutor1,
                            "detallesDenuncia": denuncia,
                            "horaDenuncia": admin.firestore.Timestamp.now(),
                            "conversacionIncluida": true,
                            "idConversacion": idConversacion

                        }

                    )
                })

            }

            var count2 = 0;
            for (var i = 0; i < mensajesConversacion.docs.length; i++) {
                batchEscritura2.delete(admin.firestore().collection("mensajes").doc(mensajesConversacion.docs[i].id)
                )
                count2 = count2 + 1;

                if (count2 > 400) {
                    await batchEscritura2.commit();
                    batchEscritura2 = admin.firestore().batch();
                    count2 = 0;
                }

            }
            await batchEscritura2.commit();
            await batchEliminacionMensajes.commit();






        }

        return { "estado": "correcto", "mensaje": "" }


    } catch (e) {
        return { "estado": "incorrecto", "mensaje": e }
    }


})



export const crearConversaciones = functions.https.onCall(async (data) => {


    const idInterlocutor1: string = data["idEmisor"];
    const idInterlocutor2: string = data["idDestino"];
    const idValoracionEliminar: string = data["idValoracion"];
    const idConversacion: string = idAleatorio();
    const interlocutor2 = await iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor2).get();
    const interlocutor1 = await iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor1).get();
    const horaCreacionConversacion: admin.firestore.Timestamp = admin.firestore.Timestamp.now();
    const idMensajes: string = idAleatorio();
    const batchEscrituraCreadorConversaciones: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();
    var imagenInterlocutor1: string = "cero";
    var hashInterlocutor1: string = "cero";
    var hashInterlocutor2: string = "cero";
    var imagenInterlocutor2: string = "cero";
    var tokenNotificacionInterlocutor1: string = interlocutor1.get("tokenNotificacion");
    var tokenNotificacionInterlocutor2: string = interlocutor2.get("tokenNotificacion");
    var valoracion = await iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(idValoracionEliminar).get();
    var crearConversacion = true;

    if (valoracion.exists == true) {
        if (valoracion.get("revelada") == true && valoracion.get("caducidad") > horaCreacionConversacion) {
            crearConversacion = true;
        }

    }


    if (crearConversacion == true) {
        if (interlocutor1.get("IMAGENPERFIL1") !== null && interlocutor1.get("IMAGENPERFIL1") !== undefined && interlocutor1.get("IMAGENPERFIL1") !== "vacio") {

            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL1")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL1")["hash"]

        }
        if (interlocutor1.get("IMAGENPERFIL2") !== null && interlocutor1.get("IMAGENPERFIL2") !== undefined && interlocutor1.get("IMAGENPERFIL2") !== "vacio" && imagenInterlocutor1 === "cero") {

            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL2")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL2")["hash"]

        }
        if (interlocutor1.get("IMAGENPERFIL3") !== null && interlocutor1.get("IMAGENPERFIL3") !== undefined && interlocutor1.get("IMAGENPERFIL3") !== "vacio" && imagenInterlocutor1 === "cero") {
            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL3")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL3")["hash"]

        }
        if (interlocutor1.get("IMAGENPERFIL4") !== null && interlocutor1.get("IMAGENPERFIL4") !== undefined && interlocutor1.get("IMAGENPERFIL4") !== "vacio" && imagenInterlocutor1 === "cero") {
            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL4")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL4")["hash"]

        }
        if (interlocutor1.get("IMAGENPERFIL5") !== null && interlocutor1.get("IMAGENPERFIL5") !== undefined && interlocutor1.get("IMAGENPERFIL5") !== "vacio" && imagenInterlocutor1 === "cero") {
            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL5")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL5")["hash"]

        }
        if (interlocutor1.get("IMAGENPERFIL6") !== null && interlocutor1.get("IMAGENPERFIL6") !== undefined && interlocutor1.get("IMAGENPERFIL6") !== "vacio" && imagenInterlocutor1 === "cero") {

            imagenInterlocutor1 = interlocutor1.get("IMAGENPERFIL6")["Imagen"]
            hashInterlocutor1 = interlocutor1.get("IMAGENPERFIL6")["hash"]

        }






        if (interlocutor2.get("IMAGENPERFIL1") !== null && interlocutor2.get("IMAGENPERFIL1") !== undefined && interlocutor2.get("IMAGENPERFIL1") !== "vacio") {

            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL1")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL1")["hash"]

        }
        if (interlocutor2.get("IMAGENPERFIL2") !== null && interlocutor2.get("IMAGENPERFIL2") !== undefined && interlocutor2.get("IMAGENPERFIL2") !== "vacio" && imagenInterlocutor2 === "cero") {

            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL2")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL2")["hash"]

        }
        if (interlocutor2.get("IMAGENPERFIL3") !== null && interlocutor2.get("IMAGENPERFIL3") !== undefined && interlocutor2.get("IMAGENPERFIL3") !== "vacio" && imagenInterlocutor2 === "cero") {
            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL3")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL3")["hash"]

        }
        if (interlocutor2.get("IMAGENPERFIL4") !== null && interlocutor2.get("IMAGENPERFIL4") !== undefined && interlocutor2.get("IMAGENPERFIL4") !== "vacio" && imagenInterlocutor2 === "cero") {
            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL4")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL4")["hash"]

        }
        if (interlocutor2.get("IMAGENPERFIL5") !== null && interlocutor2.get("IMAGENPERFIL5") !== undefined && interlocutor2.get("IMAGENPERFIL5") !== "vacio" && imagenInterlocutor2 === "cero") {
            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL5")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL5")["hash"]

        }
        if (interlocutor2.get("IMAGENPERFIL6") !== null && interlocutor2.get("IMAGENPERFIL6") !== undefined && interlocutor2.get("IMAGENPERFIL6") !== "vacio" && imagenInterlocutor2 === "cero") {

            imagenInterlocutor2 = interlocutor2.get("IMAGENPERFIL6")["Imagen"]
            hashInterlocutor2 = interlocutor2.get("IMAGENPERFIL6")["hash"]

        }









        ///creamos la conversacion que enviaremos al [interlocutor1]
        batchEscrituraCreadorConversaciones.create(iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor1).collection("conversaciones").doc(idConversacion), {
            "creacionConversacion": horaCreacionConversacion, "idConversacion": idConversacion, "idMensajes": idMensajes, "tokenNotificacion": tokenNotificacionInterlocutor2,
            "idRemitente": idInterlocutor2, "idUsuario": idInterlocutor1, "imagenRemitente": imagenInterlocutor2, "hash": hashInterlocutor2, "creadoPorMatch": false, "notificarMatchUsuario": ""
            , "conectado": false, escribiendo: false, nombreRemitente: interlocutor2.get("Nombre"), "bloqueado": false
        })

        /// creamos la conversacion para el interlocutor2
        /// creamos la conversacion que enviaremos al [interlocutor1]
        batchEscrituraCreadorConversaciones.create(iniciarFirestore.firestore().collection("usuarios").doc(idInterlocutor2).collection("conversaciones").doc(idConversacion), {
            "creacionConversacion": horaCreacionConversacion, "idConversacion": idConversacion, "idMensajes": idMensajes, "tokenNotificacion": tokenNotificacionInterlocutor1,
            "idRemitente": idInterlocutor1, "idUsuario": idInterlocutor2, "imagenRemitente": imagenInterlocutor1, "hash": hashInterlocutor1, "creadoPorMatch": false, "notificarMatchUsuario": ""
            , "conectado": false, escribiendo: false, nombreRemitente: interlocutor1.get("Nombre"), "bloqueado": false
        })



        batchEscrituraCreadorConversaciones.delete(iniciarFirestore.firestore().collection("valoraciones").doc(idValoracionEliminar));
        batchEscrituraCreadorConversaciones.delete(iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(idValoracionEliminar));




        try {
            await batchEscrituraCreadorConversaciones.commit();

        } catch (e) {
            return { "estado": "error", "tipo": "chat", "mensaje": 0 }

        }

        try {

            if (tokenNotificacionInterlocutor2 !== undefined || tokenNotificacionInterlocutor2 !== null) {

                await iniciarFirestore.messaging().sendToDevice(tokenNotificacionInterlocutor2, { data: { tipoNotificacion: "conversacion" } }, { priority: "high", contentAvailable: true })



            }

        } catch (e) {
            return { "estado": "correcto", "tipo": "chat", "mensaje": 0 }


        }


        return { "estado": "correcto", "tipo": "chat", "mensaje": 0 }








    }

    else {
        return { "estado": "error", "mensaje": "accion_no_permitida" };
    }








})




export const eliminarValoraciones = functions.https.onCall(async (data) => {
    const idSolicitudEliminar: string = data["idValoracion"];

    const eliminacionPorLotes: admin.firestore.WriteBatch = iniciarFirestore.firestore().batch();

    eliminacionPorLotes.delete(iniciarFirestore.firestore().collection("valoraciones").doc(idSolicitudEliminar));
    eliminacionPorLotes.delete(iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(idSolicitudEliminar));


})














export const dejarEnLeido = functions.https.onCall(async (data) => {
    const listaMensajesDejarLeido: string[] = data["listaIds"];
    listaMensajesDejarLeido.forEach(async (elemento) => {
        await iniciarFirestore.firestore().
            collection("mensajes")
            .doc(elemento).update({ "mensajeLeido": true });
    });

    return null



});







function idAleatorio(): string {


    var primerCaracter: number = Math.floor(Math.random() * 20) + 1
    var idCreado: string = "";
    const listaNumeros: string[] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
    const listaLetras: string[] = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z"];
    idCreado = listaLetras[primerCaracter]



    for (let _ in listaLetras) {
        var seleccionadorNumerico: number = Math.floor(Math.random() * 8) + 1
        var seleccionadorAlfabetico: number = Math.floor(Math.random() * 23) + 1
        var seleccionadorTipoCaracter: number = Math.floor(Math.random() * 3) + 1



        /// letra mayuscula
        if (seleccionadorTipoCaracter === 1) {

            idCreado += listaLetras[seleccionadorAlfabetico].toUpperCase();
        }

        /// letra minuscula
        if (seleccionadorTipoCaracter === 2) {
            idCreado += listaLetras[seleccionadorAlfabetico].toLowerCase();
        }
        /// numero
        if (seleccionadorTipoCaracter === 3) {
            idCreado += listaNumeros[seleccionadorNumerico];
        }





    }






    return idCreado;

}



export const crearUsuario = functions.https.onCall(async (data, context) => {


    var error: boolean = false;


    if (context.auth?.uid !== undefined) {
        const id: string = context.auth?.uid
        const edadTemporal: number = data["Edad"];
        const nombreTemporal: string = data["nombre"];
        const sexo: boolean = data["Sexo"];
        const fechaNacimientoTemporal: number = data["fechaNacimiento"];
        const idUsuarioTemporal: string = context.auth.uid;
        const descripcionTemporal: string = data["Descripcion"];
        const latidudTemporal: number = data["latitud"];
        const longitudTemporal: number = data["longitud"];
        const datosRapidosTemporales: Record<string, any> = data["Filtros usuario"];
        const ajustesTemporales: Record<string, any> = data["Ajustes"];
        const batchEscritraCreacionUsuario = iniciarFirestore.firestore().batch();
        const verificado: Record<string, any> = { "status": false, "error": false, "notificado": false, "limiteVerificacion": (admin.firestore.Timestamp.now().seconds + (86400 * 7)) };
        const monedasInfinitas: boolean = false;
        const cantidadSuperLikes: number = 1;
        //    const mapaSanciones = { "": "" };
        const tiempoRestanteCargaSuperLikes: number = 0;
        const tiempoRestaneCargaPuntos: number = 0;
        var longitudGeneral = 0;
        var latitudGeneral = 0;
        if (data["IMAGENPERFIL1"] !== undefined && data["IMAGENPERFIL1"] !== null) {
            if (data["IMAGENPERFIL1"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL1"]) === false) {
                    error = true;
                    console.log(1);
                }
                else {

                }
            }


        }
        else {
            data["IMAGENPERFIL1"] = { "Imagen": "vacio", "hash": "vacio" }


        }
        if (data["IMAGENPERFIL2"] !== undefined && data["IMAGENPERFIL2"] !== null) {
            if (data["IMAGENPERFIL2"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL2"]) === false) {
                    error = true;
                    console.log(2);

                }
                else {

                }
            }


        }
        else {
            data["IMAGENPERFIL2"] = { "Imagen": "vacio", "hash": "vacio" }


        }
        if (data["IMAGENPERFIL3"] !== undefined && data["IMAGENPERFIL3"] !== null) {
            if (data["IMAGENPERFIL3"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL3"]) === false) {
                    error = true;
                    console.log(3);

                }
                else {

                }
            }
            else {
                data["IMAGENPERFIL3"]["Imagen"] = "vacio"
                data["IMAGENPERFIL3"]["hash"] = "vacio"

            }

        }
        else {

            data["IMAGENPERFIL3"] = { "Imagen": "vacio", "hash": "vacio" }

        }
        if (data["IMAGENPERFIL4"] !== undefined && data["IMAGENPERFIL4"] !== null) {
            if (data["IMAGENPERFIL4"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL4"]) === false) {
                    error = true; console.log(4);

                }
                else {

                }
            }
            else {
                data["IMAGENPERFIL4"]["Imagen"] = "vacio"
                data["IMAGENPERFIL4"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL4"] = { "Imagen": "vacio", "hash": "vacio" }


        }
        if (data["IMAGENPERFIL5"] !== undefined && data["IMAGENPERFIL5"] !== null) {
            if (data["IMAGENPERFIL5"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL5"]) === false) {
                    error = true; console.log(5);

                }
                else {

                }
            }
            else {
                data["IMAGENPERFIL5"]["Imagen"] = "vacio"
                data["IMAGENPERFIL5"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL5"] = { "Imagen": "vacio", "hash": "vacio" }


        }
        if (data["IMAGENPERFIL6"] !== undefined && data["IMAGENPERFIL6"] !== null) {
            if (data["IMAGENPERFIL6"]["Imagen"] !== null) {
                if (verificarHashesImagenes(data["IMAGENPERFIL6"]) === false) {
                    error = true;
                    console.log(6);

                }
                else {

                }
            }
            else {
                data["IMAGENPERFIL6"]["Imagen"] = "vacio"
                data["IMAGENPERFIL6"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL6"] = { "Imagen": "vacio", "hash": "vacio" }

        }


        if (nombreTemporal !== null && nombreTemporal !== undefined) {
            if (nombreTemporal.length <= 23) {

            }
        }



        else {
            error = true;
            console.log(7);

        }

        if (admin.firestore.Timestamp.now().toMillis() - fechaNacimientoTemporal >= (567648000 * 1000)) {

        }
        else {
            error = true;
            console.log(8);

        }

        if (idUsuarioTemporal === id) {

        }
        else {
            error = true; console.log(9);

        }
        if (descripcionTemporal !== null && descripcionTemporal !== undefined) {
            if (descripcionTemporal.length <= 300) {

            }
        }

        else {
            error = true; console.log(10);

        }
        if (latidudTemporal <= 90 && latidudTemporal >= -90) {

        }
        else {
            error = true; console.log(11);

        }
        if (longitudTemporal <= 180 && longitudTemporal >= -180) {

        }
        else {
            error = true; console.log(12);

        }

        if (verificarDatosRapidos(datosRapidosTemporales) === true) {

        }
        else {
            error = true; console.log(13);

        }
        if (verificarAjustes(ajustesTemporales) === true) {

        }
        else {
            error = true;
        }




        if (edadTemporal >= 18 && edadTemporal <= 70) {


        }
        else {
            error = true; console.log(14);

        }
        if (longitudTemporal > 0) {
            var pointIndex = longitudTemporal.toString().indexOf(".");

            longitudGeneral = parseFloat(longitudTemporal.toString().substring(0, pointIndex + 2));

        }
        if (longitudTemporal < 0) {
            var pointIndex = longitudTemporal.toString().indexOf(".");

            longitudGeneral = parseFloat(longitudTemporal.toString().substring(0, pointIndex + 2));

        }
        if (latidudTemporal > 0) {
            var pointIndex = latidudTemporal.toString().indexOf(".");

            latitudGeneral = parseFloat(latidudTemporal.toString().substring(0, pointIndex + 2));

        }
        if (latidudTemporal < 0) {
            var pointIndex = latidudTemporal.toString().indexOf(".");

            latitudGeneral = parseFloat(latidudTemporal.toString().substring(0, pointIndex + 2));

        }

        batchEscritraCreacionUsuario.set(iniciarFirestore.firestore().collection("verificationDataCollection").doc(id), { "handGesture": "", "verified": false, "verificationAttempts": 0, "status": kProfileNotReviewed, "verificationTicketId": "", "female": true, "image": "","results":[] }),

            batchEscritraCreacionUsuario.set(iniciarFirestore.firestore().collection("usuarios").doc(id), {
                "Ajustes": ajustesTemporales,
                "Descripcion": descripcionTemporal,
                "Edad": edadTemporal,
                "posicionLat": latidudTemporal,
                "posicionLon": longitudTemporal,
                "primeraRecompensa": true,
                "IMAGENPERFIL1": { "Imagen": data["IMAGENPERFIL1"]["Imagen"], "hash": data["IMAGENPERFIL1"]["hash"], "index": 1, "pictureName": "IMAGENPERFIL1", "removed": false },
                "IMAGENPERFIL2": { "Imagen": data["IMAGENPERFIL2"]["Imagen"], "hash": data["IMAGENPERFIL2"]["hash"], "index": 2, "pictureName": "IMAGENPERFIL2", "removed": false },
                "IMAGENPERFIL3": { "Imagen": data["IMAGENPERFIL3"]["Imagen"], "hash": data["IMAGENPERFIL3"]["hash"], "index": 3, "pictureName": "IMAGENPERFIL3", "removed": false },
                "IMAGENPERFIL4": { "Imagen": data["IMAGENPERFIL4"]["Imagen"], "hash": data["IMAGENPERFIL4"]["hash"], "index": 4, "pictureName": "IMAGENPERFIL4", "removed": false },
                "IMAGENPERFIL5": { "Imagen": data["IMAGENPERFIL5"]["Imagen"], "hash": data["IMAGENPERFIL5"]["hash"], "index": 5, "pictureName": "IMAGENPERFIL5", "removed": false },
                "IMAGENPERFIL6": { "Imagen": data["IMAGENPERFIL6"]["Imagen"], "hash": data["IMAGENPERFIL6"]["hash"], "index": 6, "pictureName": "IMAGENPERFIL6", "removed": false },
                "esperandoRecompensa": false,
                "email": context.auth.token?.email,
                "filtros usuario": datosRapidosTemporales,
                "id": context.auth.uid,
                "Nombre": nombreTemporal, "Sexo": sexo,
                "estaConectado": false,
                "fechaNacimiento": fechaNacimientoTemporal,
                "siguienteRecompensa": 0,
                "monedasInfinitas": monedasInfinitas,
                "cantidadSuperLikes": cantidadSuperLikes,
                "siguientesPuntosParaDar": tiempoRestaneCargaPuntos,
                "siguientesSuperLikes": tiempoRestanteCargaSuperLikes,
                "ultimaConexion": admin.firestore.Timestamp.now().seconds,
                "usuariosBloqueados": ["c"],
                "ultimaValoracion": 0,
                "usuarioVisible": true,
                "idTareaSiguienteRecompensa": "",
                "cantidadValoraciones": 0,
                "mediaTotal": 0,
                "puntuacionTotal": 0,
                "longitud": [longitudGeneral],
                "lon": longitudGeneral,
                "lat": latitudGeneral,
                "ticketSuscripcion": "",
                "idSuscripcion": "",
                "estadoPagoSuscripcion": "NO_SUSCRITO",

                "caducidadSuscripcion": 0,
                "periodoGracia": false,

                "creditos": 0,
                "sancionado": {
                    "usuarioSancionado": false, "moderado": false, "finSancion": 0,


                }, "verificado": verificado
            });

        batchEscritraCreacionUsuario.set(iniciarFirestore.firestore().collection("expedientes").doc(id), {
            "cantidadDenuncias": 0, "denuncias": [],
            "sancionado": false,
            "bloqueadoHasta": 0,
            "idTareaSiguienteRecompensa": "",
            "imagenes": [
                data["IMAGENPERFIL1"]["Imagen"],
                data["IMAGENPERFIL2"]["Imagen"],
                data["IMAGENPERFIL3"]["Imagen"],
                data["IMAGENPERFIL4"]["Imagen"],
                data["IMAGENPERFIL5"]["Imagen"],
                data["IMAGENPERFIL6"]["Imagen"],],

            "vecesProcesado": 0
        })


        if (error === false) {
            return batchEscritraCreacionUsuario.commit().then(() => {
                return { "estado": "correcto", "mensaje": "" }
            });

        }
        else {
            return { "estado": "error", "mensaje": "" }
        }


















    }
    else {
        return { "estado": "error", "mensaje": "" }
    }








})


function verificarDatosRapidos(datos: Record<string, any>): boolean {

    try {
        const alcohol: number = datos["Alcohol"];
        const busco: number = datos["Busco"];
        const complexion: number = datos["Complexion"];
        const hijos: number = datos["Hijos"];
        const mascotas: number = datos["Mascotas"];
        const politica: number = datos["Politca"];
        const viveCon: number = datos["Que viva con"];
        const tabaco: number = datos["Tabaco"];



        if ((alcohol >= 0 && alcohol <= 4) &&
            (busco >= 0 && busco <= 4) && (complexion >= 0 && complexion <= 5) &&
            (hijos >= 0 && hijos <= 3) && (mascotas >= 0 && mascotas <= 4) &&
            (politica >= 0 && politica <= 4) && (viveCon >= 0 && viveCon <= 3) &&
            (tabaco >= 0 && tabaco <= 4)) {
            return true;
        }
        else {
            return false;

        }

    }

    catch {

        return false

    }





}

function verificarAjustes(datos: Record<string, any>): boolean {

    try {
        const edadInicial: number = datos["edadInicial"];
        const edadFinal: number = datos["edadFinal"];
        const mostrarCm: boolean = datos["enCm"];
        const mostrarMillas: boolean = datos["enMillas"];
        const mostrarMujeres: boolean = datos["mostrarMujeres"];
        const distanciaMaxima: number = datos["distanciaMaxima"];
        const mostrarPerfil: boolean = datos["mostrarPerfil"];

        if ((edadFinal >= 18 && edadFinal <= 71) && (edadInicial >= 18 && edadInicial <= 71) && (distanciaMaxima >= 10 && distanciaMaxima <= 150) && mostrarMujeres !== null && mostrarCm !== null && mostrarPerfil !== null && mostrarMillas !== null) {
            return true;
        }
        else {
            return false
        }

    }









    catch {
        return false;
    }

}


function verificarHashesImagenes(datos: Record<string, any>) {


    var imagenesValidas: boolean = true;



    var esValido: boolean = isBlurhashValid(datos["hash"]).result
    if (esValido === false) {
        imagenesValidas = false;
    }



    return imagenesValidas;
}

export const editarAjustes = functions.https.onCall(async (data, context) => {


    try {
        const distanciaMaxima: number = data["distanciaMaxima"];
        const edadFinal: number = data["edadFinal"];
        const edadInicial: number = data["edadInicial"];
        const enCm: boolean = data["enCm"];
        const enMillas: boolean = data["enMillas"];
        const mostrarAmbosSexos: boolean = data["mostrarAmbosSexos"];
        const mostrarMujeres: boolean = data["mostrarMujeres"];
        const mostrarPerfil: boolean = data["mostrarPerfil"];
        const mostrarNotaPerfil: boolean = data["mostrarNotaPerfil"];
        console.log(data);

        if ((distanciaMaxima >= 10 && distanciaMaxima <= 150) && edadFinal <= 70 && edadFinal >= 18 && edadInicial >= 18 && edadFinal >= edadInicial) {
            await iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string).update({
                "Ajustes": {
                    "distanciaMaxima": distanciaMaxima, "edadFinal": edadFinal,
                    "edadInicial": edadInicial, "enCm": enCm, "enMillas": enMillas,
                    "mostrarAmbosSexos": mostrarAmbosSexos, "mostrarMujeres": mostrarMujeres,
                    "mostrarNotaPerfil": mostrarNotaPerfil, "mostrarPerfil": mostrarPerfil
                }
            });
            return { "estado": "correcto", "mensaje": "" }


        }
        else {
            return { "estado": "error", "mensaje": "ERROR_IN_INPUT_DATA" }

        }

    } catch (e) {
        return { "estado": "correcto", "mensaje": e }

    }


})

export const editUser = functions.https.onCall(async (data, context) => {

    if (context.auth?.uid != null) {

        const images: Record<string, any>[] = data["imagenes"];
        const bio: string = data["descripcion"];
        const filtrosUsuario: Record<string, any> = data["filtros usuario"];
        const batchEscritura = iniciarFirestore.firestore().batch();



        images.forEach((element) => {
            var variableName: string = element["pictureName"];
            var removed: boolean = element["removed"];
            if (variableName.length > 0) {
                if (removed === true) {
                    batchEscritura.update(iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string), { [variableName]: { "Imagen": "vacio", "hash": "vacio", } })


                }
                else {
                    batchEscritura.update(iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string), { [variableName]: element })


                }


            }

        });

        batchEscritura.update(iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string), { "Descripcion": bio });
        batchEscritura.update(iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string), { "filtros usuario": filtrosUsuario });


        await batchEscritura.commit();


        return { "estado": "correcto" };





    }
    return { "estado": "error" };

})




export const editarUsuario = functions.https.onCall(async (data, context) => {


    var error: boolean = false;


    if (context.auth?.uid !== undefined) {


        const id: string = data["id"]
        const idUsuarioTemporal: string = context.auth.uid;
        const descripcionTemporal: string = data["Descripcion"];
        const latidudTemporal: number = data["latitud"];
        const longitudTemporal: number = data["longitud"];
        const datosRapidosTemporales: Record<string, any> = data["Filtros usuario"];
        const ajustesTemporales: Record<string, any> = data["Ajustes"];
        const citasConTemporal: number = data["Citas con"];
        const batchEscritraCreacionUsuario = iniciarFirestore.firestore().batch();
        var longitudGeneral = 0;


        if (data["IMAGENPERFIL1"] !== undefined && data["IMAGENPERFIL1"] !== null) {
            if (data["IMAGENPERFIL1"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL1"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }


        }
        else {
            data["IMAGENPERFIL1"]["Imagen"] = "vacio"
            data["IMAGENPERFIL1"]["hash"] = "vacio"

        }
        if (data["IMAGENPERFIL2"] !== undefined && data["IMAGENPERFIL2"] !== null) {
            if (data["IMAGENPERFIL2"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL2"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }


        }
        else {
            data["IMAGENPERFIL2"]["Imagen"] = "vacio"
            data["IMAGENPERFIL2"]["hash"] = "vacio"

        }
        if (data["IMAGENPERFIL3"] !== undefined && data["IMAGENPERFIL3"] !== null) {
            if (data["IMAGENPERFIL3"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL3"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }
            else {
                data["IMAGENPERFIL3"]["Imagen"] = "vacio"
                data["IMAGENPERFIL3"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL3"]["Imagen"] = "vacio"
            data["IMAGENPERFIL3"]["hash"] = "vacio"

        }
        if (data["IMAGENPERFIL4"] !== undefined && data["IMAGENPERFIL4"] !== null) {
            if (data["IMAGENPERFIL4"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL4"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }
            else {
                data["IMAGENPERFIL4"]["Imagen"] = "vacio"
                data["IMAGENPERFIL4"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL2"]["Imagen"] = "vacio"
            data["IMAGENPERFIL2"]["hash"] = "vacio"

        }
        if (data["IMAGENPERFIL5"] !== undefined && data["IMAGENPERFIL5"] !== null) {
            if (data["IMAGENPERFIL5"]["Imagen"] !== "vacio") {
                if (verificarHashesImagenes(data["IMAGENPERFIL5"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }
            else {
                data["IMAGENPERFIL5"]["Imagen"] = "vacio"
                data["IMAGENPERFIL5"]["hash"] = "vacio"

            }

        }
        else {
            data["IMAGENPERFIL2"]["Imagen"] = "vacio"
            data["IMAGENPERFIL2"]["hash"] = "vacio"

        }
        if (data["IMAGENPERFIL6"] !== undefined && data["IMAGENPERFIL6"] !== null) {
            if (data["IMAGENPERFIL6"]["Imagen"] !== null) {
                if (verificarHashesImagenes(data["IMAGENPERFIL6"]) === false) {
                    error = true;
                }
                else {

                    error = true
                }
            }
            else {
                data["IMAGENPERFIL6"]["Imagen"] = "vacio"
                data["IMAGENPERFIL6"]["hash"] = "vacio"

            }

        }









        else {
            error = true;
        }



        if (idUsuarioTemporal === id) {
            error = false;

        }
        else {
            error = true;
        }
        if (descripcionTemporal.length <= 600) {
            error = false;

        }
        else {
            error = true;
        }
        if (latidudTemporal <= 90 && latidudTemporal >= -90) {
            error = false;

        }
        else {
            error = true;
        }
        if (longitudTemporal <= 180 && longitudTemporal >= -180) {
            error = false;

        }
        else {
            error = true;
        }

        if (verificarDatosRapidos(datosRapidosTemporales)) {
            error = false;

        }
        else {
            error = true;
        }
        if (verificarAjustes(ajustesTemporales)) {
            error = false;

        }
        else {
            error = true;
        }


        if (citasConTemporal >= 0 && citasConTemporal < 3) {
            error = false;

        }
        else {
            error = true;
        }

        if (longitudTemporal > 0) {
            longitudGeneral = parseFloat(longitudTemporal.toString().substring(0, 3));


        }
        if (longitudTemporal < 0) {
            longitudGeneral = parseFloat(longitudTemporal.toString().substring(0, 4));

        }



        batchEscritraCreacionUsuario.update(iniciarFirestore.firestore().collection("usuarios").doc(id), {
            "Ajustes": ajustesTemporales,
            "Descripcion": descripcionTemporal,
            "Citas con": citasConTemporal,
            "posicionLat": latidudTemporal,
            "posicionLon": longitudTemporal,
            "enlaceComparteGana": data["enlaceComparteGana"],
            "longitud": [longitudGeneral],


            "IMAGENPERFIL1": { "Imagen": data["IMAGENPERFIL1"]["Imagen"], "hash": data["IMAGENPERFIL1"]["hash"] },
            "IMAGENPERFIL2": { "Imagen": data["IMAGENPERFIL2"]["Imagen"], "hash": data["IMAGENPERFIL2"]["hash"] },
            "IMAGENPERFIL3": { "Imagen": data["IMAGENPERFIL3"]["Imagen"], "hash": data["IMAGENPERFIL3"]["hash"] },
            "IMAGENPERFIL4": { "Imagen": data["IMAGENPERFIL4"]["Imagen"], "hash": data["IMAGENPERFIL4"]["hash"] },
            "IMAGENPERFIL5": { "Imagen": data["IMAGENPERFIL5"]["Imagen"], "hash": data["IMAGENPERFIL5"]["hash"] },
            "IMAGENPERFIL6": { "Imagen": data["IMAGENPERFIL6"]["Imagen"], "hash": data["IMAGENPERFIL6"]["hash"] },
            "usuarioVisible": ajustesTemporales["mostrarPerfil"],
            "filtros usuario": datosRapidosTemporales,
            "id": id,
        });

        if (error === false) {
            return batchEscritraCreacionUsuario.commit().then(() => {
                return { "estado": "correcto", "mensaje": "" }
            });

        }
        else {
            return { "estado": "error", "mensaje": "error_datos_registro" }

        }
    }
    else {
        return { "estado": "error", "mensaje": "error_crear_usuarios" }
    }








})

export const linkComparteGana = functions.https.onCall(async (data) => {
    const idEmisorRecompensa = data["id"];
    const codigoRecompensa = data["codigo"];
    const linkRecompensa = data["link"];


    return admin.firestore().collection("comparteGana").doc(codigoRecompensa).set({ "idEmisor": idEmisorRecompensa, "caducado": false, "idGanador": "", "idPendiente": "", "codigo": codigoRecompensa, "link": linkRecompensa, "abierto": true });
})

export const enlazarPerfilRecompensa = functions.https.onCall(async (data) => {
    const idUsuario = data["id"];
    const codigoRecompensa = data["codigo"];
    const documentoEnlaceRecompensa = await admin.firestore().collection("comparteGana").doc(codigoRecompensa).get();
    const idPendiente: string = documentoEnlaceRecompensa.get("idPendiente");
    const batchEscritura = admin.firestore().batch();
    const documentoUsuario = await admin.firestore().collection("usuarios").doc(idUsuario).get();

    if (documentoUsuario.exists) {
        return "recompensa_no_disponible";
    }
    else {
        if (idPendiente.length > 0) {
            return "recompesa_no_disponible";
        }

        else {
            batchEscritura.update(admin.firestore().collection("comparteGana").doc(codigoRecompensa), { "idGanador": "", "idPendiente": idUsuario, "abierto": false })
            await batchEscritura.commit();

            return "hecho"



        }
    }




})



export const solicitarUsuarioDeterminado = functions.https.onCall(async (data, context) => {
    const idUsuarioDeterminado = data["id"];
    var usuarioDeterminado;

    try {
        usuarioDeterminado = await admin.firestore().collection("usuarios").doc(idUsuarioDeterminado).get();
        if (usuarioDeterminado.exists == true) {


            return {
                "estado": "correcto",
                "datos": {
                    "identificador": usuarioDeterminado.get("id"), "nombre": usuarioDeterminado.get("Nombre"), "Edad": usuarioDeterminado.get("Edad"),
                    "IMAGENPERFIL1": usuarioDeterminado.get("IMAGENPERFIL1"),
                    "IMAGENPERFIL2": usuarioDeterminado.get("IMAGENPERFIL2"),
                    "IMAGENPERFIL3": usuarioDeterminado.get("IMAGENPERFIL3"),
                    "IMAGENPERFIL4": usuarioDeterminado.get("IMAGENPERFIL4"),
                    "fechaNacimiento": usuarioDeterminado.get("fechaNacimiento"),
                    "IMAGENPERFIL5": usuarioDeterminado.get("IMAGENPERFIL5"),
                    "IMAGENPERFIL6": usuarioDeterminado.get("IMAGENPERFIL6"),
                    "distancia": 0,
                    "verificado": usuarioDeterminado.get("verificado")["status"],
                    "Descripcion": usuarioDeterminado.get("Descripcion"),
                    "filtrosUsuario": usuarioDeterminado.get("filtros usuario"),
                }

            }
        }
        else {
            return { "estado": "error", "mensaje": "usuario_no_existe", "tipo": "solicitarUsuarioDeterminado" };
        }
    }
    catch (e) {
        return { "estado": "error", "mensaje": e, "tipo": "solicitarUsuarioDeterminado" };

    }
})




export const solicitarUsuarios = functions.runWith({ memory: "2GB", "timeoutSeconds": 300 }).https.onCall(async (data, context) => {
    try {
        const idSolicitante: string = context.auth?.uid as string
        const sexo: boolean = data["sexo"];
        var latitud: number = data["latitud"];
        var longitud: number = data["longitud"];
        var longitudPura = data["longitud"];
        var latitudPura = data["latitud"];

        const distancia: number = data["distancia"];
        const ambosSexos: boolean = data["ambosSexos"];
        const edadInicial: number = data["edadInicial"];
        const edadFinal: number = data["edadFinal"];
        const latitudMaxima: number = getProfiles.calcularLatitudMaxima(latitud, distancia);
        const latitudMinima: number = getProfiles.calcularLatitudMinima(latitud, distancia);
        const documentoUsuario = await admin.firestore().collection("usuarios").doc(idSolicitante).get();
        const longitudesEste: number[] = getProfiles.calcularlongitudMaxima(longitud, distancia);
        const longitudesOeste: number[] = getProfiles.calcularlongitudMinima(longitud, distancia);
        var longitudesTotales: number[] = [];
        var latitudesTotales: number[] = [];
        var listaPerfiles: Map<string, any>[] = [];
        var resultadoFuncion: Record<string, any>;

        await iniciarFirestore.firestore().collection("usuarios").doc(context.auth?.uid as string).update({ "longitud": [parseFloat(longitud.toFixed(1))], "lat": latitud, "posicionLat": latitudPura, "posicionLon": longitudPura });


        longitudesTotales = longitudesTotales.concat(longitudesEste);
        longitudesTotales = longitudesTotales.concat(longitudesOeste)



        console.log(latitudesTotales);
        console.log(longitudesTotales)
        console.log(distancia)


        if (documentoUsuario.get("Ajustes")["mostrarPerfil"] === true) {




            resultadoFuncion = await getProfiles.solicitarUsuariosFirestore(distancia, ambosSexos, edadInicial, edadFinal,
                sexo, idSolicitante, documentoUsuario, longitudesTotales, latitudMaxima, latitudMinima, latitudPura, longitudPura);
            var listaTemporal: Map<string, any>[] = resultadoFuncion["listaPerfiles"];
            listaPerfiles = listaPerfiles.concat(listaTemporal);


            console.log("fin bucle for mayor");
            console.log("fin funcion");

            return { "estado": "correcto", "mensaje": listaPerfiles }

        }
        else {
            return {
                "estado": "error",
                "tipo": "solicitarPerfilesUsuarios",
                "mensaje": "error_perfil_invisible"
            }
        }

    } catch (e) {

        await notificarErroresEscuchadoresEventos({ "error": e, "funcion": "solcitar_usuarios" })
        return {
            "estado": "error",
            "tipo": "solicitarPerfilesUsuarios",
            "mensaje": "error_interno"
        }
    }


})

/**
 * Funcion ejecutada por google Tasks, esta funcion se encarga de enviar la notificacion de recompensa en FCM
 */

export const enviarNotificacionRecompensa = functions.https.onRequest(async (req, resp) => {
    const { CloudTasksClient } = require('@google-cloud/tasks')



    const usuario = req.body
    var docUsuario = await iniciarFirestore.firestore().collection("usuarios").doc(usuario.idUsuario).get();
    var idTareaSiguieteRecompensa: string = docUsuario.get("idTareaSiguienteRecompensa");
    var tokenNotificacion: string = docUsuario.get("tokenNotificacion");
    const tareaNube = new CloudTasksClient();
    if (idTareaSiguieteRecompensa === "") {
        return null;
    }

    return iniciarFirestore.messaging().sendToDevice(tokenNotificacion, { data: { tipoNotificacion: "recompensa" } }, { priority: "high", contentAvailable: true }).then((data) => {
        return tareaNube.deleteTask({ name: idTareaSiguieteRecompensa })



    }).catch((errro) => {
        console.error(errro);
        resp.status(500).send(errro);
    })
})





async function ponerNotificacionRecompensaEnEspera(idUsuario: string, marcaTiempoSegundos: number, eliminarTarea: boolean) {
    const { CloudTasksClient } = require('@google-cloud/tasks')

    const tareaNube = new CloudTasksClient();
    const rutaQueue: string = tareaNube.queuePath("hotty-189c7", "us-west4", "recompensa-diaria");

    if (eliminarTarea === false) {
        const task = {
            httpRequest: {
                httpMethod: 'POST',

                url: "https://us-central1-hotty-189c7.cloudfunctions.net/enviarNotificacionRecompensa",

                body: Buffer.from(JSON.stringify({ idUsuario })).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: marcaTiempoSegundos,
            }
        }

        const [respuestaCreacionTarea] = await tareaNube.createTask({ parent: rutaQueue, task });
        return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({ "idTareaSiguienteRecompensa": respuestaCreacionTarea.name });

    }
    if (eliminarTarea === true) {
        var documentoUsuario = await admin.firestore().collection("usuarios").doc(idUsuario).get();
        var idTarea = documentoUsuario.get("idTareaSiguienteRecompensa");
        if (idTarea !== "" && idTarea !== null && idTarea !== undefined) {
            return tareaNube.deleteTask({ name: idTarea })

        }
        else {
            return null
        }

    }





}
/**
 * @param idValoracion
 * Identificador valoracion a eliminar
 * @param marcaTiempoSegundos fecha o marca de tiempo en la que se va a ejecutar la tarea de eliminar automaticamente la valoracion
 * @param eliminarTarea si es true entonces esta funcion en vez de crear una tarea la eliminará, si es true la marca de tiempo puede ser cero
 * 
 * 
 * Funcion para programar la tarea de  eliminacion de las valoraciones caducadas, o para eliminar la tarea creada si la valoracion ha sido eliminada por accion del usuario (rechazar o aceptar)
 * 
 */
async function programadorTareaEliminacionValoraciones(idValoracion: string, marcaTiempoSegundos: number, eliminarTarea: boolean, idTarea: string): Promise<any> {
    const { CloudTasksClient } = require('@google-cloud/tasks')

    const tareaNube = new CloudTasksClient();
    const rutaQueue: string = tareaNube.queuePath("hotty-189c7", "us-west4", "eliminador-valoraciones");
    if (eliminarTarea === false) {
        const task = {
            httpRequest: {
                httpMethod: 'POST',

                url: "https://us-central1-hotty-189c7.cloudfunctions.net/tareaEliminarValoraciones",

                body: Buffer.from(JSON.stringify({ idValoracion })).toString('base64'),
                headers: {
                    'Content-Type': 'application/json',
                },
            },
            scheduleTime: {
                seconds: marcaTiempoSegundos,
            }
        }

        const [paqueteTarea] = await tareaNube.createTask({ parent: rutaQueue, task });
        console.log(paqueteTarea);
        return paqueteTarea.name;
    }
    if (eliminarTarea === true) {
        return tareaNube.deleteTask({ name: idTarea });

    }










}


/**
 * Funcion ejecutada por google Tasks, esta funcion se encarga de eliminar una  valoracion cuando esta caduca
 */
// @ts-ignore

export const tareaEliminarValoraciones = functions.https.onRequest(async (req, resp) => {



    const cuerpo = req.body
    const batchEliminacionValoraciones = admin.firestore().batch();



    const existePublica = (await admin.firestore().collection("valoraciones").doc(cuerpo.idValoracion).get()).exists;
    const valoracion = (await admin.firestore().collection("valoraciones").doc(cuerpo.idValoracion).get());


    if (existePublica === true) {

        var revelada = valoracion.get("revelada");

        if (revelada === true) {
            batchEliminacionValoraciones.delete(admin.firestore().collection("valoraciones").doc(cuerpo.idValoracion))
            batchEliminacionValoraciones.delete(admin.firestore().collection("valoracionesPrivadas").doc(cuerpo.idValoracion))

            try {

                resp.status(200).send("correcto")
                await batchEliminacionValoraciones.commit();
                return null;



            }
            catch (e) {
                resp.status(500).send(e);
                return null;
            }
        }
        else {
            return null;
        }





    }
    if (existePublica === false) {
        resp.status(500).send("finalizado");

        return null;
    }




})


export const cambioToken = functions.https.onCall((data) => {
    const tokenNuevo: string = data["token"];
    const idUsuario: string = data["idUsuario"];


    return iniciarFirestore.firestore().collection("usaurios").where("tokenNotificacion", "==", tokenNuevo).orderBy("ultimaConexion", "asc").get().then(async (value) => {
        value.docs.forEach(async (documento) => {
            if (idUsuario !== documento.id) {
                await documento.ref.update({ "tokenNotificacion": "" })

            }
            else {
                await documento.ref.update({ "tokenNotificacion": tokenNuevo })
            }


        })
    })
})

export const establecerToken = functions.https.onCall((data) => {
    const tokenNuevo: string = data["token"];
    const idUsuario: string = data["idUsuario"];


    return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({ "tokenNotificacion": tokenNuevo, "ultimaConexion": (admin.firestore.Timestamp.now().seconds), }).then(() => {
        return iniciarFirestore.firestore().collection("usaurios").where("tokenNotificacion", "==", tokenNuevo).orderBy("ultimaConexion", "asc").get().then(async (value) => {
            value.docs.forEach(async (documento) => {
                if (idUsuario !== documento.id) {
                    await documento.ref.update({ "tokenNotificacion": "" })

                }
                else {
                    await documento.ref.update({ "tokenNotificacion": tokenNuevo })
                }


            })
        })
    });
})

export const eliminarToken = functions.https.onCall((data) => {
    const idUsuario: string = data["idUsuario"];


    return iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).update({ "tokenNotificacion": "", });
})


export const borrarUsuario = functions.runWith({
    timeoutSeconds: 540,
    memory: '2GB'
}).https.onCall(async (data) => {

    try {
        const idUsuario = data["id"];
        const batchEliminacion: admin.firestore.WriteBatch = admin.firestore().batch();

        var batchEliminacionMensajesUsuario: admin.firestore.WriteBatch = admin.firestore().batch();

        var batchEliminacionValoraciones: admin.firestore.WriteBatch = admin.firestore().batch();

        var batchEliminacionValoracionesPrivadas: admin.firestore.WriteBatch = admin.firestore().batch();

        var batchEliminacionConversaciones: admin.firestore.WriteBatch = admin.firestore().batch();
        var contadorOperacionesBatchConversaciones = 0;
        var contadorOperacionesBatchMensajes = 0;
        var contadorOperacionesBatchValoracionesPrivadas = 0;
        var contadorOperacionesBatchValoraciones = 0;








        batchEliminacion.delete(iniciarFirestore.firestore().collection("usuarios").doc(idUsuario));
        batchEliminacion.delete(iniciarFirestore.firestore().collection("presenciaUsuario").doc(idUsuario));
        batchEliminacion.delete(iniciarFirestore.firestore().collection("expedientes").doc(idUsuario));




        /// Eliminamos las conversaciones creadas en ambos usuarios
        /// dentro del bucle for each si el contador de batch supera los 450 hacemos commit y empezamos con otro batch



        const conversaciones: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).collection("conversaciones").get();
        conversaciones.docs.forEach(async (conversacion) => {
            var idRemitente = conversacion.get("idRemitente")
            batchEliminacionConversaciones.delete(iniciarFirestore.firestore().collection("usuarios").doc(idUsuario).collection("conversaciones").doc(conversacion.id));
            batchEliminacionConversaciones.delete(iniciarFirestore.firestore().collection("usuarios").doc(idRemitente).collection("conversaciones").doc(conversacion.id));
            contadorOperacionesBatchConversaciones = contadorOperacionesBatchConversaciones + 1;
            if (contadorOperacionesBatchConversaciones > 450) {
                await batchEliminacionConversaciones.commit();
                batchEliminacionConversaciones = admin.firestore().batch();
                contadorOperacionesBatchConversaciones = 0;

            }



        })
        await batchEliminacionConversaciones.commit();

        /// Eliminamos los mensajes creadas en ambos usuarios
        /// dentro del bucle for each si el contador de batch supera los 450 hacemos commit y empezamos con otro batch


        var mensajesChats: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await iniciarFirestore.firestore().collection("mensajes").where("interlocutores", 'array-contains-any', [idUsuario]).get();
        mensajesChats.docs.forEach(async (mensajes) => {
            batchEliminacionMensajesUsuario.delete(mensajes.ref);

            contadorOperacionesBatchMensajes = contadorOperacionesBatchMensajes + 1;
            console.log("enmensajes")
            if (contadorOperacionesBatchMensajes > 450) {
                await batchEliminacionMensajesUsuario.commit();
                batchEliminacionMensajesUsuario = admin.firestore().batch();
                contadorOperacionesBatchMensajes = 0;
                console.log("reiniciandoBAtch")


            }
        })
        await batchEliminacionMensajesUsuario.commit();



        const valoracionesPrivadas: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await iniciarFirestore.firestore().collection("valoracionesPrivadas").where("Id emisor", "==", idUsuario).get();




        const valoraciones: FirebaseFirestore.QuerySnapshot<FirebaseFirestore.DocumentData> = await iniciarFirestore.firestore().collection("valoraciones").where("idDestino", "==", idUsuario).get();

        valoracionesPrivadas.docs.forEach(async (valoracion) => {

            batchEliminacionValoracionesPrivadas.delete(valoracion.ref)
            batchEliminacionValoracionesPrivadas.delete(iniciarFirestore.firestore().collection("valoraciones").doc(valoracion.id))

            contadorOperacionesBatchValoracionesPrivadas = contadorOperacionesBatchValoracionesPrivadas + 2;

            if (contadorOperacionesBatchValoracionesPrivadas > 450) {
                await batchEliminacionValoracionesPrivadas.commit();
                batchEliminacionValoracionesPrivadas = admin.firestore().batch();
                contadorOperacionesBatchValoracionesPrivadas = 0;

            }

        })
        valoraciones.docs.forEach(async (valoracion) => {

            batchEliminacionValoraciones.delete(valoracion.ref)
            batchEliminacionValoraciones.delete(iniciarFirestore.firestore().collection("valoracionesPrivadas").doc(valoracion.id))
            contadorOperacionesBatchValoraciones = contadorOperacionesBatchValoraciones + 2;

            if (contadorOperacionesBatchValoraciones > 450) {
                await batchEliminacionValoraciones.commit();
                batchEliminacionValoraciones = admin.firestore().batch();
                contadorOperacionesBatchValoraciones = 0;

            }

        })

        await batchEliminacionValoraciones.commit();
        await batchEliminacionValoracionesPrivadas.commit()



        await admin.auth().deleteUser(idUsuario);
        var storageRef = admin.storage().bucket();







        await storageRef.deleteFiles({ prefix: `${data.id}` },)


        await batchEliminacion.commit();

        return { "estado": "correcto" }



    } catch (e) {
        return { "estado": "error" }

    }





})

export const escuchadorEliminacionValoraciones = functions.firestore.document("valoraciones/{valoracionesID}").onDelete(async (data) => {
    const idValoracion = data.id;
    try {
        await admin.firestore().collection("valoracionesPrivadas").doc(idValoracion).delete();


    }
    catch (e) {
        notificarErroresEscuchadoresEventos({ "estado": "error", "mensaje": e, "funcion": "escuchadorEliminacionValoraciones" });
    }

    return programadorTareaEliminacionValoraciones(idValoracion, 0, true, data.get("idTarea"));

})


export const desbloquearPerfil = functions.https.onCall(async (data) => {
    try {

        const userId = data["userId"];
        var expedienteUsuario: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData> = await admin.firestore().collection("expedientes").doc(userId).get();
        var documentoUsuario: FirebaseFirestore.DocumentSnapshot<FirebaseFirestore.DocumentData> = await admin.firestore().collection("usuarios").doc(userId).get();
        var batchExpedientes = admin.firestore().batch();

        if (expedienteUsuario.exists && documentoUsuario.exists) {
            var fechaLimiteBloqueo: number = expedienteUsuario.get("bloqueadoHasta");
            var fechaActualMilisegundos = admin.firestore.Timestamp.now().toMillis();

            if (fechaLimiteBloqueo <= fechaActualMilisegundos) {
                batchExpedientes.update(admin.firestore().collection("expedientes").doc(userId), {
                    "bloqueadoHasta": 0, "cantidadDenuncias": 0, "denuncias": [], "sancionado": false
                })
                batchExpedientes.update(admin.firestore().collection("usuarios").doc(userId), {
                    "sancionado": {
                        "finSancion": 0, "moderado": false, "usuarioSancionado": false
                    }, "Ajustes.mostrarPerfil": true
                })
                await batchExpedientes.commit();

                return { "estado": "correcto" }





            }
            else {
                return { "estado": "error" }

            }


        }
        else {
            return { "estado": "error" }

        }
    } catch (e) {
        return { "estado": "error", }

    }


});
