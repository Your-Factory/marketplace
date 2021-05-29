import * as THREE from "/static/js/three/three.module.js"
import {DDSLoader} from "/static/js/three/DDSLoader.js";
import {MTLLoader} from "/static/js/three/MTLLoader.js";
import {OBJLoader} from "/static/js/three/OBJLoader.js";
import {OrbitControls} from "/static/js/three/OrbitControls.js";

let camera, scene, renderer, controls;

function changeToScene(model_txt) {
    let main_image = document.getElementById('main_image');
    while (main_image.firstChild) {
        main_image.removeChild(main_image.lastChild);
    }

    let model = JSON.parse(model_txt);

    let container = document.createElement('div');
    container.setAttribute('class', 'main_product_image');
    main_image.appendChild(container);

    init(container, model);
    animate();
}

function init(container, model_bytes) {
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 2000);
    camera.position.z = 20;

    scene = new THREE.Scene();

    const ambientLight = new THREE.AmbientLight(0x9ab4ff, 0.4);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    camera.add(directionalLight);
    scene.add(camera);

    function loadModel() {
        object.traverse(function (child) {
            if (child.isMesh) child.material.map = texture;
        });

        object.position.y = 0;
        scene.add(object);
    }

    const manager = new THREE.LoadingManager(loadModel);

    let loader = new OBJLoader(manager);
    let model = loader.parse(model_bytes);
    scene.add(model);

    // new MTLLoader(manager)
    //     .setPath("/static/models")
    //     .load('/suzanne.mtl', function (materials) {
    //         materials.preload();
    //
    //         new OBJLoader(manager)
    //             .setMaterials(materials)
    //             .setPath("/static/models")
    //             .load('/suzanne.obj', function (object) {
    //                 object.position.y = 0;
    //                 scene.add(object);
    //             });
    //     });

    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);

    controls = new OrbitControls(camera, renderer.domElement);
    controls.listenToKeyEvents(window);

    window.addEventListener('resize', onWindowResize);
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize(window.innerWidth, window.innerHeight);
}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    render();
}

function render() {
    camera.lookAt(scene.position);
    renderer.render(scene, camera);
}

window.changeToScene = changeToScene;
