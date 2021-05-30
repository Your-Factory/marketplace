function changeImage(element) {
    let main_image = document.getElementById('main_image');
    while (main_image.firstChild) {
        main_image.removeChild(main_image.lastChild);
    }

    let img = document.createElement('img');
    img.setAttribute('class', 'main_product_image');
    img.src = element.src;
    img.width = 500;
    main_image.appendChild(img);
    // let main_prodcut_image = document.getElementById('main_product_image');
    // main_prodcut_image.src = element.src;
}