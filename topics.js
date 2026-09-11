/* BioVerseAR — single source of truth for the 7 topics.
   Adding real content to a locked topic later = flip `ready` to true and set `model`.
   That's the only change needed; the dashboard and AR view are fully data-driven.
   Badge names are fixed per the project scope — do not rename. */
window.TOPICS = [
  {
    id: 'animal-cells',
    name: 'Animal Cells',
    badge: 'Cellular Architect',
    phase: 1,
    ready: true,
    model: 'assets/models/animal_cell.glb',
    scene: 'cell-warm', // AR backdrop (see model-viewer.scene-* in styles.css)
    // Real optimized asset: 795,812 bytes, Draco-required (KHR_draco_mesh_compression)
    // + WebP textures. Draco decoder is vendored locally, so it renders with no network.

    // Attribution is required by the model's CC-BY license — render it in the AR view.
    credit: {
      what: '3D model & annotations', // this topic's labels are verbatim from the author
      title: 'Animal cell 2.0 — annotated in English',
      author: 'montanna',
      url: 'https://sketchfab.com/3d-models/animal-cell-20-annotated-in-english-0d9f7f4257224975b2ef83a283709b2f',
      license: 'CC BY 4.0'
    },
    // Annotation TEXT is verbatim from montanna's model (CC-BY, credited above).
    // Numbering matches the original model (1 Golgi … 5 Smooth ER). Positions were
    // sampled on OUR mesh at each organelle's location (from the user's screenshot),
    // so they sit on the right parts; fine-tune any pin via author mode (?author=1).
    annotations: [
      { id: 1, title: 'Golgi Apparatus', position: '0.06126 -0.00108 0.16052', normal: '0.80999 -0.13181 0.57145',
        body: "The Golgi apparatus (also known as the Golgi body) packages proteins and lipids into vesicles, preparing them to be delivered throughout the cell." },
      { id: 2, title: 'Mitochondria', position: '-0.01625 0.00294 0.20321', normal: '-0.27104 0.69175 0.66934',
        body: "The mitochondria, or mitochondrion, is the only organelle that has its own genome and can reproduce by fission. It has two membranes and is responsible for making energy, storing calcium and controlling functions like cell growth and death." },
      { id: 3, title: 'Rough Endoplasmic Reticulum', position: '-0.02150 -0.02222 0.05267', normal: '0.02236 -0.04114 0.99890',
        body: "The Rough Endoplasmic Reticulum, or rough ER, differs from the smooth ER in that its surface is covered with bumpy ribosomes. These help the ER synthesize and target proteins. Since it's so close to the nucleus, it is able to communicate with it about protein synthesis." },
      { id: 4, title: 'Nucleus', position: '-0.04244 0.01079 -0.02709', normal: '0 1 0.00108',
        body: "The nucleus is the main control center of the cell. It has its own double membrane and contains a gel-like substance called nucleoplasm, which holds internal structures like the nucleolus. The nucleolus is made up of tightly coiled chromosomes that hold the cell's entire genetic code. The nucleus uses this information to communicate with the rough ER about protein synthesis." },
      { id: 5, title: 'Smooth Endoplasmic Reticulum', position: '-0.10418 0.00976 0.12139', normal: '-0.83528 0.17464 0.52136',
        body: "The smooth endoplasmic reticulum differs from the rough ER in that it has no ribosomes on its surface. It synthesizes lipids and hormones." }
    ]
  },
  // Topics 2-7: quiz content is live (real 30-question bank each). Their AR 3D models
  // aren't sourced yet, so `model` stays null -> the topic hub shows "3D model coming
  // soon" for AR while Pre/Post quizzes work. Drop in a model + flip nothing else:
  // ar.html and the hub read `model` directly. Set an `annotations` array when the
  // model has hotspots.
  { id: 'human-cells',  name: 'Human Cells', badge: 'DNA Decycler', phase: 2, ready: true, model: 'assets/models/human_cell.glb', scene: 'cell-cool',
    credit: { title: 'Human Cell', author: 'markdragan', url: 'https://sketchfab.com/3d-models/human-cell-60ef7d2515b0403986ff9e8b7f234a66', license: 'CC BY 4.0' },
    // Pins placed via annotate.html (positions sampled on our mesh). Bodies are
    // drafts — teacher to review/replace.
    annotations: [
      { id: 1,  title: 'DNA',                         position: '-0.02519 0.01561 0.00371',  normal: '-0.12086 -0.05583 -0.99110', body: "The cell's genetic instructions, coiled up inside the nucleus. It tells the cell how to build proteins and how to work." },
      { id: 2,  title: 'Nucleolus',                   position: '-0.03470 0.00327 0.00930',  normal: '0.82049 0.49034 -0.29387',   body: "A dense spot inside the nucleus where ribosomes are made." },
      { id: 3,  title: 'Nucleus',                     position: '-0.05508 0.02688 0.00426',  normal: '0.88263 0.08795 -0.46176',   body: "The control centre of the cell. It holds the DNA and directs the cell's activities." },
      { id: 4,  title: 'Mitochondrion',               position: '-0.08844 -0.00913 -0.08768', normal: '-0.04586 -0.99716 -0.05982', body: "The cell's powerhouse. It releases energy from food for the cell to use." },
      { id: 5,  title: 'Golgi Apparatus',             position: '0.01799 -0.00052 -0.08704',  normal: '-0.00749 0.99964 -0.02572',  body: "Packages and sorts proteins, then ships them to where they are needed." },
      { id: 6,  title: 'Lysosome',                    position: '0.00001 -0.00969 -0.10184',  normal: '0.02847 0.99478 -0.09800',   body: "Holds enzymes that break down waste and worn-out parts to keep the cell clean." },
      { id: 7,  title: 'Cytoplasm',                   position: '0.14366 -0.01405 -0.01633',  normal: '-0.04151 0.99839 -0.03873',  body: "The jelly-like fluid that fills the cell and holds the organelles in place." },
      { id: 8,  title: 'Rough Endoplasmic Reticulum', position: '-0.04369 -0.01287 0.07928',  normal: '-0.08968 0.98914 0.11649',   body: "A folded membrane covered in ribosomes that builds and moves proteins." },
      { id: 9,  title: 'Centrosome',                  position: '0.03457 -0.01128 0.11908',   normal: '0.04447 -0.26579 0.96300',   body: "Helps organise the cell and pulls chromosomes apart when the cell divides." },
      { id: 10, title: 'Ribosomes',                   position: '-0.00153 -0.00303 0.14287',  normal: '-0.51382 0.55702 0.65247',   body: "Tiny factories that read the DNA's instructions and assemble proteins." }
    ] },
  { id: 'life-sciences', name: 'Life Sciences', badge: 'Eco-Explorer', phase: 2, ready: true, model: 'assets/models/plant_cell.glb', scene: 'flora',
    credit: { title: 'Plant Cell Organelles', author: 'CVallance', url: 'https://sketchfab.com/3d-models/plant-cell-organelles-e61e7bdf8c8449a583b364f05e70289b', license: 'CC BY 4.0' },
    // Pins placed via annotate.html. Bodies are drafts — teacher to review/replace.
    annotations: [
      { id: 1, title: 'Chloroplast',                 position: '0.02451 -0.00968 -0.17203', normal: '-0.19897 0.38923 0.89939', body: "Where photosynthesis happens. It captures sunlight and turns it into food (sugar) for the plant." },
      { id: 2, title: 'Ribosomes',                   position: '0.05511 0.02764 -0.16759',  normal: '0.19594 0.04108 0.97976',  body: "Tiny factories that read the DNA's instructions and build proteins." },
      { id: 3, title: 'Mitochondrion',               position: '0.12030 -0.02649 -0.10514', normal: '0.00940 0.91467 0.40409',  body: "The cell's powerhouse. It releases energy from food for the cell to use." },
      { id: 4, title: 'Golgi Apparatus',             position: '0.14735 0.02567 -0.02508',  normal: '-0.90698 0.07553 0.41435', body: "Packages and sorts proteins, then ships them to where they are needed." },
      { id: 5, title: 'Nucleolus',                   position: '0.05813 -0.02120 0.05916',  normal: '-0.30746 0.90413 -0.29668', body: "A dense spot inside the nucleus where ribosomes are made." },
      { id: 6, title: 'Rough Endoplasmic Reticulum', position: '0.11143 -0.02715 0.11096',  normal: '0.59287 0.77335 0.22458',  body: "A folded membrane covered in ribosomes that builds and moves proteins." },
      { id: 7, title: 'Central Vacuole',             position: '-0.01817 0.01929 -0.06849', normal: '-0.06594 0.99578 -0.06382', body: "A large fluid-filled sac that stores water and keeps the plant cell firm and upright." },
      { id: 8, title: 'Cell Wall',                   position: '-0.11592 -0.04508 -0.01049', normal: '-0.99701 0.07726 0.00284', body: "A tough outer layer around the plant cell that gives it shape and support." },
      { id: 9, title: 'Cell Membrane',               position: '-0.06314 -0.02075 0.11073', normal: '-0.54989 0.42673 0.71800', body: "A thin barrier just inside the cell wall that controls what enters and leaves the cell." }
    ] },
  { id: 'earth-space',  name: 'Earth & Space Sciences', badge: 'Starlight Scout', phase: 2, ready: true, model: 'assets/models/solar_system.glb', space: true,
    credit: { title: 'Solar system', author: 'Cybertron B-127', url: 'https://sketchfab.com/3d-models/solar-system-9d8106724a0a4ea8af194535d5957f99', license: 'CC BY 4.0' },
    // Pins placed via annotate.html on the orrery. Bodies are drafts — teacher to review/replace.
    annotations: [
      { id: 1, title: 'Sun',     position: '-0.01313 0.00615 0.00331',  normal: '-0.80622 0.53054 0.26180', body: "The star at the centre of our solar system. Its gravity holds all the planets in orbit, and its light and heat make life on Earth possible." },
      { id: 2, title: 'Mercury', position: '-0.00433 0.00407 -0.03474', normal: '0.17220 0.78393 0.59649',  body: "The smallest planet and the closest to the Sun. It has almost no atmosphere, so it is scorching by day and freezing at night." },
      { id: 3, title: 'Venus',   position: '-0.01260 0.00785 -0.06272', normal: '0.21929 0.55755 0.80065',  body: "The hottest planet, wrapped in thick clouds that trap heat like a blanket. It is about the same size as Earth." },
      { id: 4, title: 'Earth',   position: '0.03600 0.00765 -0.05249',  normal: '-0.11580 0.99314 -0.01627', body: "Our home planet — the only one known to have liquid water and life. It sits in the zone that is not too hot and not too cold." },
      { id: 5, title: 'Mars',    position: '0.06331 -0.01159 0.05472',  normal: '-0.20608 0.47195 -0.85720', body: "The \"Red Planet,\" coloured by rusty iron dust. It has the tallest volcano and the largest canyon in the solar system." },
      { id: 6, title: 'Jupiter', position: '-0.10460 0.01122 0.04644',  normal: '0.77541 0.32170 -0.54337', body: "The largest planet — a giant ball of gas with a famous Great Red Spot, a storm bigger than the whole Earth." },
      { id: 7, title: 'Saturn',  position: '0.13756 -0.00556 -0.07710', normal: '-0.42992 0.73911 -0.51854', body: "Famous for its bright rings made of ice and rock. It is a gas giant and the second-largest planet." },
      { id: 8, title: 'Uranus',  position: '-0.15025 0.03283 -0.10937', normal: '0.28298 0.91429 0.28983',  body: "An icy giant that spins on its side, so it rolls around the Sun like a ball. Methane gas gives it a blue-green colour." },
      { id: 9, title: 'Neptune', position: '-0.16226 0.00351 0.14341',  normal: '0.80275 -0.30780 -0.51073', body: "The farthest planet from the Sun — a cold, windy ice giant with the fastest winds in the solar system." }
    ] },
  { id: 'matter',       name: 'Matter',                 badge: 'Particle Picker', phase: 2, ready: true, model: 'assets/models/atom.glb', scene: 'matter',
    credit: { title: 'Atom', author: 'arloopa', url: 'https://sketchfab.com/3d-models/atom-6a283d5b19c34e2b8fcfc6907b231aea', license: 'CC BY 4.0' },
    // Pins placed via annotate.html on the atom. Bodies are drafts — teacher to review/replace.
    annotations: [
      { id: 1, title: 'Electron Orbits', position: '0.00022 0.09304 -0.08195',  normal: '-0.99999 0.00539 0.00064', body: "The paths the electrons follow as they move around the nucleus. Each orbit, or shell, sits at a set distance from the centre." },
      { id: 2, title: 'Electron',        position: '-0.03141 0.01110 -0.11107',  normal: '-0.61232 -0.75020 -0.24952', body: "A tiny, negatively charged particle that zips around the nucleus. It is far lighter than a proton or a neutron." },
      { id: 3, title: 'Neutron',         position: '-0.01665 0.03203 -0.01047',  normal: '-0.03154 0.73101 -0.68164', body: "A particle in the nucleus with no electric charge. It adds mass and helps hold the nucleus together." },
      { id: 4, title: 'Proton',          position: '-0.00120 0.03163 -0.02657',  normal: '-0.21715 0.80064 -0.55840', body: "A positively charged particle in the nucleus. The number of protons decides which element the atom is." }
    ] },
  { id: 'force-motion', name: 'Force & Motion',         badge: 'Friction Fighter',phase: 2, ready: true, model: 'assets/models/pendulum.glb', scene: 'lab',
    credit: { title: 'Triple Pendulum Mechanism', author: 'trinityscsp', url: 'https://sketchfab.com/3d-models/triple-pendulum-mechanism-2131be1593554a049eb0ac29cb8c6b72', license: 'CC BY 4.0' },
    // Triple pendulum. Loads PAUSED (every arm swings, so labels would drift) — Play
    // spins it. Bodies tie each part to the Force & Motion quiz concepts; drafts for
    // teacher review. Titles are the user's; the "combs/sector" are the linked arcs.
    annotations: [
      { id: 1, title: 'Top Comb',     position: '-0.00314 0.11761 -0.10931', normal: '-0.23108 0.35219 -0.90695', body: "Part of the top arm of the pendulum. It swings on a pivot, and because all three arms are linked, its motion passes down to the arms below it." },
      { id: 2, title: 'Metal Sector', position: '-0.08555 0.07106 0.00969', normal: '0.97880 0.06778 -0.19327', body: "A curved metal arc that guides the swinging motion. The arms sweep along arcs like this as gravity and their own momentum carry them." },
      { id: 3, title: 'Inner Sphere', position: '-0.01042 0.07704 0.00802', normal: '-0.54737 -0.22345 0.80651', body: "A heavy metal ball — a mass of the pendulum. Gravity pulls it down with a force W = mg, and its inertia keeps it moving once it has been set going." },
      { id: 4, title: 'Bottom Comb',  position: '0.03244 0.05376 0.06292', normal: '-0.16733 0.11156 -0.97957', body: "Part of the lowest arm. Because the arms are all linked, a tiny change at the top makes the bottom swing wildly — this is why a triple pendulum is famous for chaotic motion." },
      { id: 5, title: 'Base',         position: '-0.05587 -0.01968 0.11605', normal: '-0.00000 0.97860 -0.20580', body: "The heavy stand that anchors the pendulum. Its large mass gives it plenty of inertia, so it stays still while the arms swing above it." },
      { id: 6, title: 'Crank Handle', position: '0.20024 0.06733 0.00534', normal: '0.03026 -0.70768 0.70588', body: "Turn this to set the pendulum going — the input push (a force) that gives the arms the energy they need to start moving." }
    ] },
  // `animate: true` = auto-play the model's animation in the AR view. Leave it off
  // for models whose labels must stay locked to parts (e.g. the solar-system orrery,
  // whose planets orbit) — those load paused so hotspots sit on the right part, and a
  // Play/Pause control lets students watch the motion when they want.
  { id: 'energy',       name: 'Energy',                 badge: 'Spark Starter',   phase: 2, ready: true, model: 'assets/models/wind_turbine.glb', scene: 'energy',
    credit: { title: 'Animated Wind Turbine', author: 'Glowbox 3D', url: 'https://sketchfab.com/3d-models/animated-wind-turbine-e0678e6615a74ed29c1376a591262159', license: 'CC BY 4.0' },
    // Animated (spinning blades) but loads PAUSED so the labels stay on their part
    // (Play button spins it). Pins via annotate.html; bodies are drafts — teacher to review.
    annotations: [
      { id: 1, title: 'Blades',    position: '-0.00285 0.41247 0.02689', normal: '-0.66732 -0.00113 0.74477', body: "The three long arms that catch the wind. As the wind pushes them, they spin the rotor around." },
      { id: 2, title: 'Rotor Hub', position: '-0.00244 0.29086 0.04006', normal: '-0.41167 -0.43746 0.79947', body: "The centre piece the blades attach to. It turns as the blades spin and passes that motion to the shaft inside." },
      { id: 3, title: 'Nacelle',   position: '-0.00367 0.30836 0.01110', normal: '0.00000 0.99830 -0.05827', body: "The housing at the top of the tower. It holds the gearbox, generator, and controls that turn spinning motion into electricity." },
      { id: 4, title: 'Generator', position: '0.01089 0.28155 -0.00477', normal: '0.92073 -0.39020 0.00000', body: "The part that converts the spinning motion into electrical energy — where the wind's energy becomes electricity." },
      { id: 5, title: 'Tower',     position: '-0.00687 0.20165 0.00058', normal: '-1.00000 0.00000 0.00000', body: "The tall pole that holds the turbine high up, where the wind is stronger and steadier." }
    ] }
];
