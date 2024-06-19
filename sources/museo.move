module direccion::museo_de_memes {
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_framework::randomness;
    use std::simple_map::{SimpleMap,Self};

    struct Meme has store, copy {
        id: u16,
        creado_por: address,
        titulo: String,
        url: String,
    }

    struct Museo has key, store, copy {
        memes: SimpleMap<u16, Meme>
    }

    // Funciones Internas
    fun obtener_id_random(): u16 {
        randomness::u16_integer()
    }

    fun inicializar_museo(firma: &signer) {
        let direccion_firma = signer::address_of(firma);
        if (!exists<Museo>(direccion_firma)) {
            move_to<Museo>(firma, Museo{
                memes: simple_map::new(),
            });
        };
    }

    //Funciones externas
    #[randomness]
    entry fun crear_meme(
        firma: &signer, 
        titulo: String, 
        url: String,
    ) acquires Museo {
        inicializar_museo(firma);

        let id: u16 = obtener_id_random();
        let creado_por: address = signer::address_of(firma);
        let memes = borrow_global_mut<Museo>(creado_por);

        simple_map::add(&mut memes.memes, id, Meme {
            id,
            creado_por,
            titulo,
            url,
        });
    }

    #[view]
    public fun obtener_memes(direccion: address): vector<Meme> acquires Museo {
        let museo_personal = borrow_global<Museo>(direccion);
        simple_map::values(&museo_personal.memes)
    }

    public fun obtener_meme() {

    }

    #[test_only]
    use std::string::utf8;
    #[test_only]
    use std::debug::print;

    #[test(fx = @aptos_framework)]
    fun testing(fx: &signer) {
        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000000");
    }

}
