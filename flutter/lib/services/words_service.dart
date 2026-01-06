class Word {
  final String word;
  final List<String> tags;

  Word({required this.word, required this.tags});
}

final List<Word> words = [
  // Musical Instruments
  Word(word: 'piano', tags: ['musical instrument', 'keyboard instrument', 'instrument played by beethoven', 'has 88 keys', 'classical music']),
  Word(word: 'guitar', tags: ['musical instrument', 'string instrument', 'has six strings', 'used in rock music', 'acoustic or electric']),
  Word(word: 'violin', tags: ['musical instrument', 'string instrument', 'played with a bow', 'used in orchestras', 'smallest string instrument']),
  Word(word: 'drums', tags: ['musical instrument', 'percussion instrument', 'played with sticks', 'keeps the rhythm', 'part of rock bands']),
  Word(word: 'flute', tags: ['musical instrument', 'wind instrument', 'made of metal or wood', 'played sideways', 'has a high pitch']),
  Word(word: 'saxophone', tags: ['musical instrument', 'wind instrument', 'used in jazz music', 'made of brass', 'invented by adolphe sax']),
  Word(word: 'trumpet', tags: ['musical instrument', 'brass instrument', 'has three valves', 'used in jazz and classical', 'high pitched brass']),
  Word(word: 'cello', tags: ['musical instrument', 'string instrument', 'played sitting down', 'larger than violin', 'deep rich sound']),
  Word(word: 'harp', tags: ['musical instrument', 'string instrument', 'triangular shape', 'plucked with fingers', 'ancient instrument']),
  Word(word: 'accordion', tags: ['musical instrument', 'keyboard and bellows', 'used in folk music', 'portable instrument', 'squeezebox']),
  
  // Animals
  Word(word: 'elephant', tags: ['large mammal', 'has a trunk', 'largest land animal', 'lives in africa and asia', 'never forgets']),
  Word(word: 'giraffe', tags: ['tall mammal', 'long neck', 'tallest animal', 'lives in africa', 'spotted pattern']),
  Word(word: 'penguin', tags: ['flightless bird', 'lives in antarctica', 'black and white', 'excellent swimmer', 'waddles on land']),
  Word(word: 'dolphin', tags: ['marine mammal', 'intelligent creature', 'lives in ocean', 'playful animal', 'uses echolocation']),
  Word(word: 'kangaroo', tags: ['marsupial', 'hops on hind legs', 'lives in australia', 'carries baby in pouch', 'strong tail']),
  Word(word: 'cheetah', tags: ['big cat', 'fastest land animal', 'lives in africa', 'spotted fur', 'sprint hunter']),
  Word(word: 'octopus', tags: ['marine animal', 'has eight tentacles', 'intelligent invertebrate', 'can change color', 'lives underwater']),
  Word(word: 'butterfly', tags: ['insect', 'has colorful wings', 'goes through metamorphosis', 'drinks nectar', 'pollinates flowers']),
  Word(word: 'eagle', tags: ['bird of prey', 'sharp talons', 'excellent eyesight', 'symbol of freedom', 'builds nests high up']),
  Word(word: 'tiger', tags: ['big cat', 'striped pattern', 'lives in asia', 'endangered species', 'solitary hunter']),
  Word(word: 'zebra', tags: ['striped horse', 'black and white stripes', 'lives in africa', 'runs in herds', 'herbivore']),
  Word(word: 'peacock', tags: ['colorful bird', 'male has fancy tail', 'displays feathers to attract mates', 'native to india', 'iridescent plumage']),
  Word(word: 'koala', tags: ['marsupial', 'lives in australia', 'eats eucalyptus leaves', 'sleeps most of the day', 'looks like a bear']),
  Word(word: 'panda', tags: ['bear', 'black and white', 'eats bamboo', 'lives in china', 'endangered species']),
  Word(word: 'whale', tags: ['largest marine mammal', 'lives in ocean', 'breathes through blowhole', 'sings underwater songs', 'migrates long distances']),
  
  // Fruits
  Word(word: 'apple', tags: ['fruit', 'grows on trees', 'red green or yellow', 'keeps the doctor away', 'crispy and sweet']),
  Word(word: 'banana', tags: ['tropical fruit', 'yellow when ripe', 'high in potassium', 'grows in bunches', 'monkeys favorite']),
  Word(word: 'orange', tags: ['citrus fruit', 'orange color', 'high in vitamin c', 'juicy segments', 'grown in warm climates']),
  Word(word: 'strawberry', tags: ['red berry', 'seeds on outside', 'sweet fruit', 'grows close to ground', 'popular in desserts']),
  Word(word: 'watermelon', tags: ['large fruit', 'green outside red inside', 'very juicy', 'mostly water', 'summer fruit']),
  Word(word: 'pineapple', tags: ['tropical fruit', 'spiky outside', 'sweet and tangy', 'yellow flesh', 'crown on top']),
  Word(word: 'mango', tags: ['tropical fruit', 'orange flesh', 'sweet and juicy', 'large seed inside', 'king of fruits']),
  Word(word: 'grape', tags: ['small fruit', 'grows in clusters', 'used to make wine', 'red green or purple', 'grows on vines']),
  Word(word: 'cherry', tags: ['small red fruit', 'has a pit', 'grows on trees', 'sweet or tart', 'popular in pies']),
  Word(word: 'peach', tags: ['fuzzy skin', 'orange pink color', 'juicy stone fruit', 'sweet flavor', 'grows in warm climates']),
  
  // Vegetables
  Word(word: 'carrot', tags: ['root vegetable', 'orange color', 'good for eyesight', 'crunchy texture', 'high in vitamin a']),
  Word(word: 'broccoli', tags: ['green vegetable', 'looks like small trees', 'cruciferous vegetable', 'rich in nutrients', 'eaten cooked or raw']),
  Word(word: 'potato', tags: ['starchy vegetable', 'grows underground', 'versatile ingredient', 'makes french fries', 'staple food']),
  Word(word: 'tomato', tags: ['red vegetable', 'technically a fruit', 'used in sauces', 'grows on vines', 'juicy and acidic']),
  Word(word: 'lettuce', tags: ['leafy green', 'used in salads', 'crispy texture', 'low in calories', 'grows in heads']),
  Word(word: 'cucumber', tags: ['green vegetable', 'mostly water', 'refreshing taste', 'grows on vines', 'used in salads']),
  Word(word: 'pepper', tags: ['colorful vegetable', 'red yellow or green', 'sweet or spicy', 'bell shaped or long', 'rich in vitamin c']),
  Word(word: 'onion', tags: ['bulb vegetable', 'makes you cry when cut', 'layers inside', 'used in cooking', 'strong flavor']),
  Word(word: 'spinach', tags: ['leafy green', 'high in iron', 'popeyes favorite', 'eaten cooked or raw', 'nutritious vegetable']),
  Word(word: 'corn', tags: ['yellow vegetable', 'grows on cobs', 'kernels in rows', 'sweet variety exists', 'used for many products']),
  
  // Professions
  Word(word: 'doctor', tags: ['medical professional', 'treats patients', 'works in hospital', 'helps sick people', 'wears white coat']),
  Word(word: 'teacher', tags: ['educator', 'works in school', 'teaches students', 'shares knowledge', 'grades homework']),
  Word(word: 'engineer', tags: ['designs and builds', 'solves technical problems', 'uses math and science', 'creates solutions', 'builds bridges or software']),
  Word(word: 'chef', tags: ['professional cook', 'works in kitchen', 'creates dishes', 'culinary expert', 'wears tall white hat']),
  Word(word: 'pilot', tags: ['flies airplanes', 'works in aviation', 'travels the world', 'sits in cockpit', 'needs license']),
  Word(word: 'artist', tags: ['creates art', 'paints or sculpts', 'creative professional', 'works in studio', 'expresses through visuals']),
  Word(word: 'lawyer', tags: ['legal professional', 'represents clients', 'works in courtroom', 'knows the law', 'argues cases']),
  Word(word: 'nurse', tags: ['medical caregiver', 'helps doctors', 'cares for patients', 'works in hospital', 'gives medicine']),
  Word(word: 'scientist', tags: ['researches and discovers', 'works in laboratory', 'conducts experiments', 'seeks knowledge', 'uses scientific method']),
  Word(word: 'architect', tags: ['designs buildings', 'creates blueprints', 'combines art and engineering', 'plans structures', 'works with clients']),
  
  // Countries
  Word(word: 'france', tags: ['european country', 'capital is paris', 'famous for eiffel tower', 'speaks french', 'known for wine and cheese']),
  Word(word: 'japan', tags: ['asian island nation', 'capital is tokyo', 'land of rising sun', 'famous for sushi', 'advanced technology']),
  Word(word: 'brazil', tags: ['south american country', 'largest in south america', 'speaks portuguese', 'famous for amazon rainforest', 'carnival celebration']),
  Word(word: 'egypt', tags: ['african country', 'ancient pyramids', 'nile river', 'pharaohs and mummies', 'sphinx monument']),
  Word(word: 'australia', tags: ['island continent', 'home to kangaroos', 'sydney opera house', 'great barrier reef', 'southern hemisphere']),
  Word(word: 'canada', tags: ['north american country', 'second largest country', 'bilingual nation', 'famous for maple syrup', 'northern neighbor of usa']),
  Word(word: 'india', tags: ['asian country', 'second most populous', 'taj mahal', 'diverse culture', 'birthplace of yoga']),
  Word(word: 'mexico', tags: ['north american country', 'ancient aztec and maya', 'speaks spanish', 'famous for tacos', 'colorful culture']),
  Word(word: 'italy', tags: ['european country', 'shaped like boot', 'capital is rome', 'colosseum and vatican', 'famous for pizza and pasta']),
  Word(word: 'china', tags: ['asian country', 'most populous nation', 'great wall', 'ancient civilization', 'communist government']),
  
  // Sports
  Word(word: 'football', tags: ['team sport', 'played with round ball', 'most popular sport worldwide', 'goal is to score', 'called soccer in america']),
  Word(word: 'basketball', tags: ['indoor team sport', 'shoot ball through hoop', 'played on court', 'james invented it', 'five players per team']),
  Word(word: 'tennis', tags: ['racket sport', 'played on court', 'hit ball over net', 'wimbledon tournament', 'can be singles or doubles']),
  Word(word: 'baseball', tags: ['bat and ball sport', 'american pastime', 'nine innings', 'diamond shaped field', 'world series championship']),
  Word(word: 'swimming', tags: ['water sport', 'olympic event', 'different strokes', 'done in pool or open water', 'full body workout']),
  Word(word: 'cycling', tags: ['ride bicycle', 'tour de france', 'outdoor activity', 'racing sport', 'eco friendly transport']),
  Word(word: 'boxing', tags: ['combat sport', 'punch with gloves', 'in a ring', 'rounds with referee', 'muhammad ali famous']),
  Word(word: 'golf', tags: ['precision sport', 'hit ball into hole', 'uses clubs', 'played on course', 'eighteen holes']),
  Word(word: 'hockey', tags: ['team sport', 'ice or field variety', 'hit puck or ball', 'physical contact', 'goalies protect net']),
  Word(word: 'volleyball', tags: ['team sport', 'hit ball over net', 'played on court or beach', 'six players per side', 'bump set spike']),
  
  // Technology
  Word(word: 'computer', tags: ['electronic device', 'processes data', 'has keyboard and screen', 'runs software', 'desktop or laptop']),
  Word(word: 'smartphone', tags: ['mobile device', 'handheld computer', 'makes calls and texts', 'runs apps', 'touchscreen interface']),
  Word(word: 'internet', tags: ['global network', 'connects computers', 'world wide web', 'information superhighway', 'online connectivity']),
  Word(word: 'robot', tags: ['automated machine', 'performs tasks', 'artificial intelligence', 'can be programmed', 'mechanical helper']),
  Word(word: 'camera', tags: ['takes photos', 'captures images', 'digital or film', 'has lens and sensor', 'preserves memories']),
  Word(word: 'television', tags: ['display device', 'shows programs', 'broadcasts content', 'entertainment medium', 'screen in living room']),
  Word(word: 'satellite', tags: ['orbits earth', 'communication device', 'space technology', 'transmits signals', 'provides gps']),
  Word(word: 'software', tags: ['computer program', 'not physical', 'runs on hardware', 'code and algorithms', 'applications and systems']),
  Word(word: 'drone', tags: ['unmanned aircraft', 'remote controlled', 'flying camera', 'used for photography', 'autonomous flight']),
  Word(word: 'printer', tags: ['output device', 'prints on paper', 'uses ink or toner', 'produces hard copies', 'connects to computer']),
  
  // Nature
  Word(word: 'mountain', tags: ['tall landform', 'peaks and valleys', 'taller than hill', 'snow on top', 'challenge for climbers']),
  Word(word: 'ocean', tags: ['large body of water', 'saltwater', 'covers most of earth', 'home to marine life', 'five major oceans']),
  Word(word: 'forest', tags: ['many trees together', 'home to wildlife', 'produces oxygen', 'dense vegetation', 'different types exist']),
  Word(word: 'desert', tags: ['dry region', 'little rainfall', 'hot during day', 'sandy or rocky', 'cacti and camels']),
  Word(word: 'river', tags: ['flowing water', 'flows to ocean', 'fresh water', 'carved by erosion', 'used for transport']),
  Word(word: 'volcano', tags: ['mountain opening', 'erupts lava', 'molten rock inside', 'can be dormant or active', 'forms from tectonic activity']),
  Word(word: 'rainbow', tags: ['colorful arc', 'appears after rain', 'seven colors', 'refraction of light', 'sunshine and water droplets']),
  Word(word: 'lightning', tags: ['electrical discharge', 'occurs during storms', 'bright flash', 'followed by thunder', 'strikes ground from clouds']),
  Word(word: 'waterfall', tags: ['water falling', 'over cliff or rocks', 'creates mist', 'powerful force', 'tourist attraction']),
  Word(word: 'glacier', tags: ['large ice mass', 'moves slowly', 'found in cold regions', 'ancient frozen water', 'melting due to climate change']),
  
  // Transportation
  Word(word: 'airplane', tags: ['flying vehicle', 'has wings and engines', 'travels through air', 'carries passengers', 'faster than car']),
  Word(word: 'train', tags: ['runs on rails', 'multiple cars', 'passengers or cargo', 'powered by engine', 'station to station']),
  Word(word: 'bicycle', tags: ['two wheeled vehicle', 'pedal powered', 'eco friendly', 'exercise and transport', 'handlebar steering']),
  Word(word: 'boat', tags: ['water vessel', 'floats on water', 'sailing or motor', 'different sizes', 'used for fishing or travel']),
  Word(word: 'helicopter', tags: ['rotary wing aircraft', 'can hover', 'vertical takeoff', 'spinning rotor blades', 'versatile flying machine']),
  Word(word: 'submarine', tags: ['underwater vessel', 'military or research', 'sealed hull', 'periscope to see', 'can dive deep']),
  Word(word: 'motorcycle', tags: ['two wheeled motor vehicle', 'faster than bicycle', 'rider sits astride', 'helmet required', 'engine powered']),
  Word(word: 'truck', tags: ['large motor vehicle', 'hauls cargo', 'bigger than car', 'commercial use', 'heavy duty']),
  Word(word: 'bus', tags: ['public transport', 'carries many passengers', 'scheduled routes', 'larger than car', 'stops at stations']),
  Word(word: 'scooter', tags: ['small vehicle', 'stand or sit', 'two wheels', 'motor or kick powered', 'urban transportation']),
  
  // Buildings & Structures
  Word(word: 'castle', tags: ['medieval fortress', 'stone building', 'royalty lived there', 'towers and walls', 'defensive structure']),
  Word(word: 'bridge', tags: ['spans gap', 'crosses water or valley', 'connects two sides', 'engineering feat', 'vehicles or people cross']),
  Word(word: 'lighthouse', tags: ['tall tower', 'guides ships', 'light at top', 'warns of danger', 'coastal structure']),
  Word(word: 'pyramid', tags: ['ancient structure', 'triangular sides', 'egyptian tombs', 'pharaoh burial', 'massive stone blocks']),
  Word(word: 'skyscraper', tags: ['very tall building', 'many floors', 'found in cities', 'modern architecture', 'offices or apartments']),
  Word(word: 'cathedral', tags: ['large church', 'religious building', 'gothic architecture', 'ornate design', 'stained glass windows']),
  Word(word: 'stadium', tags: ['sports venue', 'seats many people', 'oval or round', 'games played here', 'large arena']),
  Word(word: 'museum', tags: ['displays exhibits', 'art or history', 'educational place', 'preserves artifacts', 'visitors learn here']),
  Word(word: 'library', tags: ['building with books', 'quiet place', 'borrow books', 'research and study', 'public resource']),
  Word(word: 'hospital', tags: ['medical facility', 'treats sick people', 'doctors and nurses', 'emergency room', 'healthcare center']),
  
  // Weather
  Word(word: 'sunshine', tags: ['bright light', 'from the sun', 'warm and bright', 'good weather', 'clear sky day']),
  Word(word: 'rain', tags: ['water falling', 'from clouds', 'wet weather', 'good for plants', 'need umbrella']),
  Word(word: 'snow', tags: ['frozen precipitation', 'white flakes', 'cold weather', 'winter phenomenon', 'covers ground']),
  Word(word: 'wind', tags: ['moving air', 'can be strong', 'causes waves', 'invisible force', 'blows things around']),
  Word(word: 'thunder', tags: ['loud sound', 'from lightning', 'during storm', 'rumbling noise', 'follows flash']),
  Word(word: 'cloud', tags: ['water vapor', 'floats in sky', 'white or gray', 'different shapes', 'brings rain']),
  Word(word: 'fog', tags: ['thick mist', 'reduced visibility', 'low lying cloud', 'water droplets in air', 'morning phenomenon']),
  Word(word: 'storm', tags: ['severe weather', 'wind and rain', 'thunder and lightning', 'dangerous conditions', 'dark clouds']),
  Word(word: 'tornado', tags: ['spinning wind', 'funnel shaped', 'very destructive', 'touches ground', 'extreme weather']),
  Word(word: 'hurricane', tags: ['tropical storm', 'very powerful', 'circular wind pattern', 'causes flooding', 'named storms']),
  
  // Food & Dishes
  Word(word: 'pizza', tags: ['italian dish', 'round flatbread', 'tomato and cheese', 'many toppings', 'baked in oven']),
  Word(word: 'burger', tags: ['sandwich', 'meat patty', 'in a bun', 'fast food', 'american classic']),
  Word(word: 'sushi', tags: ['japanese food', 'raw fish', 'with rice', 'rolled in seaweed', 'eaten with chopsticks']),
  Word(word: 'pasta', tags: ['italian food', 'wheat noodles', 'many shapes', 'served with sauce', 'carbohydrate dish']),
  Word(word: 'salad', tags: ['healthy dish', 'mixed vegetables', 'usually cold', 'dressed with oil', 'fresh ingredients']),
  Word(word: 'soup', tags: ['liquid dish', 'served hot', 'broth based', 'vegetables or meat', 'eaten with spoon']),
  Word(word: 'sandwich', tags: ['bread with filling', 'portable meal', 'named after earl', 'many varieties', 'quick lunch']),
  Word(word: 'cake', tags: ['sweet dessert', 'baked treat', 'for celebrations', 'frosting on top', 'served in slices']),
  Word(word: 'cookie', tags: ['small sweet biscuit', 'baked treat', 'chocolate chip popular', 'crispy or chewy', 'snack food']),
  Word(word: 'chocolate', tags: ['sweet treat', 'from cocoa beans', 'brown color', 'many forms', 'popular dessert']),
  
  // Household Items
  Word(word: 'chair', tags: ['furniture', 'for sitting', 'has legs and back', 'found everywhere', 'many styles']),
  Word(word: 'table', tags: ['flat surface', 'has legs', 'for eating or working', 'household furniture', 'various sizes']),
  Word(word: 'lamp', tags: ['provides light', 'has bulb', 'electrical device', 'sits on table or floor', 'illuminates room']),
  Word(word: 'mirror', tags: ['reflective surface', 'shows reflection', 'made of glass', 'hangs on wall', 'used for grooming']),
  Word(word: 'refrigerator', tags: ['keeps food cold', 'kitchen appliance', 'preserves freshness', 'has freezer section', 'runs on electricity']),
  Word(word: 'microwave', tags: ['heats food', 'kitchen appliance', 'uses radiation', 'quick cooking', 'beeps when done']),
  Word(word: 'blanket', tags: ['keeps warm', 'soft fabric', 'used on bed', 'covers body', 'cozy comfort']),
  Word(word: 'pillow', tags: ['for sleeping', 'soft cushion', 'supports head', 'filled with feathers or foam', 'on bed']),
  Word(word: 'curtain', tags: ['window covering', 'fabric hanging', 'blocks light', 'provides privacy', 'decorative element']),
  Word(word: 'clock', tags: ['tells time', 'has hands or digital', 'on wall or desk', 'mechanical or electronic', 'shows hours and minutes']),
  
  // Colors
  Word(word: 'red', tags: ['primary color', 'color of blood', 'warm color', 'associated with love', 'stop sign color']),
  Word(word: 'blue', tags: ['primary color', 'color of sky', 'cool color', 'ocean color', 'calming effect']),
  Word(word: 'green', tags: ['secondary color', 'color of grass', 'nature color', 'go signal', 'mix of blue and yellow']),
  Word(word: 'yellow', tags: ['primary color', 'color of sun', 'bright and cheerful', 'warning color', 'banana color']),
  Word(word: 'purple', tags: ['secondary color', 'royal color', 'mix of red and blue', 'violet shade', 'lavender related']),
  Word(word: 'orange', tags: ['secondary color', 'fruit named after it', 'warm color', 'sunset color', 'mix of red and yellow']),
  Word(word: 'pink', tags: ['light red', 'color of roses', 'feminine association', 'soft color', 'cherry blossom shade']),
  Word(word: 'brown', tags: ['earth color', 'wood color', 'chocolate color', 'neutral tone', 'autumn color']),
  Word(word: 'black', tags: ['darkest color', 'absence of light', 'formal color', 'night color', 'elegant shade']),
  Word(word: 'white', tags: ['lightest color', 'pure color', 'snow color', 'clean association', 'all colors combined']),
  
  // School Subjects
  Word(word: 'mathematics', tags: ['school subject', 'study of numbers', 'algebra and geometry', 'equations and formulas', 'logical thinking']),
  Word(word: 'science', tags: ['study of nature', 'experiments and theories', 'biology chemistry physics', 'scientific method', 'discovery and research']),
  Word(word: 'history', tags: ['study of past', 'ancient civilizations', 'wars and events', 'dates and timelines', 'learn from past']),
  Word(word: 'geography', tags: ['study of earth', 'maps and locations', 'countries and capitals', 'physical features', 'climate and regions']),
  Word(word: 'literature', tags: ['study of writing', 'books and poems', 'stories and novels', 'authors and classics', 'reading comprehension']),
  Word(word: 'music', tags: ['study of sound', 'playing instruments', 'reading notes', 'rhythm and melody', 'creative expression']),
  Word(word: 'art', tags: ['visual creativity', 'painting and drawing', 'sculpture and design', 'expression through visuals', 'color and form']),
  Word(word: 'physical', tags: ['gym class', 'sports and exercise', 'fitness activities', 'team games', 'healthy body']),
  Word(word: 'chemistry', tags: ['science subject', 'study of matter', 'elements and compounds', 'reactions and formulas', 'periodic table']),
  Word(word: 'biology', tags: ['life science', 'study of living things', 'cells and organisms', 'plants and animals', 'human body']),
  
  // Emotions
  Word(word: 'happiness', tags: ['positive emotion', 'feeling joy', 'smiling and laughing', 'contentment', 'good mood']),
  Word(word: 'sadness', tags: ['negative emotion', 'feeling down', 'crying and grief', 'unhappy state', 'melancholy']),
  Word(word: 'anger', tags: ['strong emotion', 'feeling mad', 'frustration', 'heated feeling', 'irritation']),
  Word(word: 'fear', tags: ['emotion of danger', 'scared feeling', 'anxiety', 'frightened state', 'worry']),
  Word(word: 'love', tags: ['deep affection', 'caring emotion', 'romantic feeling', 'attachment', 'strong bond']),
  Word(word: 'surprise', tags: ['unexpected emotion', 'shocked feeling', 'astonishment', 'sudden reaction', 'caught off guard']),
  Word(word: 'disgust', tags: ['repulsion emotion', 'distaste', 'revolted feeling', 'aversion', 'turned off']),
  Word(word: 'excitement', tags: ['enthusiastic emotion', 'eager anticipation', 'energetic feeling', 'thrilled state', 'pumped up']),
  Word(word: 'jealousy', tags: ['envious emotion', 'wanting what others have', 'resentful feeling', 'green with envy', 'covetous']),
  Word(word: 'pride', tags: ['satisfaction emotion', 'feeling accomplished', 'self respect', 'pleased with self', 'sense of worth']),
  
  // Body Parts
  Word(word: 'heart', tags: ['vital organ', 'pumps blood', 'in chest', 'beats rhythmically', 'symbol of love']),
  Word(word: 'brain', tags: ['organ in head', 'controls body', 'thinks and remembers', 'nervous system', 'intelligence center']),
  Word(word: 'hand', tags: ['end of arm', 'five fingers', 'grasps objects', 'writes and creates', 'sense of touch']),
  Word(word: 'eye', tags: ['organ of sight', 'sees world', 'on face', 'has pupil and iris', 'vision sense']),
  Word(word: 'ear', tags: ['hearing organ', 'on side of head', 'detects sound', 'has eardrum', 'balance sense']),
  Word(word: 'nose', tags: ['smelling organ', 'on face', 'breathes air', 'detects odors', 'has two nostrils']),
  Word(word: 'mouth', tags: ['eats and speaks', 'on face', 'has teeth and tongue', 'tastes food', 'forms words']),
  Word(word: 'leg', tags: ['lower limb', 'walks and runs', 'has knee joint', 'supports body', 'two per person']),
  Word(word: 'foot', tags: ['end of leg', 'walks on ground', 'has toes', 'supports weight', 'fits in shoe']),
  Word(word: 'arm', tags: ['upper limb', 'from shoulder to hand', 'has elbow joint', 'reaches and lifts', 'two per person']),
  
  // Clothing
  Word(word: 'shirt', tags: ['upper body clothing', 'has sleeves', 'buttons or pullover', 'covers torso', 'many styles']),
  Word(word: 'pants', tags: ['lower body clothing', 'covers legs', 'has two leg holes', 'worn with belt', 'trousers']),
  Word(word: 'dress', tags: ['one piece clothing', 'worn by women', 'covers body', 'formal or casual', 'skirt and top combined']),
  Word(word: 'shoes', tags: ['foot covering', 'protects feet', 'worn outside', 'laces or slip on', 'many types']),
  Word(word: 'hat', tags: ['head covering', 'protects from sun', 'fashion accessory', 'has brim', 'many styles']),
  Word(word: 'jacket', tags: ['outer clothing', 'worn over shirt', 'keeps warm', 'has zipper or buttons', 'casual or formal']),
  Word(word: 'socks', tags: ['foot clothing', 'worn inside shoes', 'covers ankle', 'comes in pairs', 'keeps feet warm']),
  Word(word: 'gloves', tags: ['hand covering', 'one for each hand', 'keeps hands warm', 'has finger slots', 'winter wear']),
  Word(word: 'scarf', tags: ['neck accessory', 'long fabric', 'wraps around neck', 'keeps warm', 'fashion item']),
  Word(word: 'sweater', tags: ['warm clothing', 'knitted garment', 'worn on top', 'pullover style', 'cozy winter wear']),
  
  // Shapes
  Word(word: 'circle', tags: ['round shape', 'no corners', 'curved line', 'wheel shape', 'perfectly round']),
  Word(word: 'square', tags: ['four equal sides', 'four right angles', 'geometric shape', 'box shape', 'symmetrical']),
  Word(word: 'triangle', tags: ['three sides', 'three angles', 'geometric shape', 'pyramid base', 'pointy top']),
  Word(word: 'rectangle', tags: ['four sides', 'opposite sides equal', 'four right angles', 'longer than wide', 'book shape']),
  Word(word: 'oval', tags: ['egg shape', 'elongated circle', 'curved shape', 'no corners', 'ellipse']),
  Word(word: 'star', tags: ['pointed shape', 'five or more points', 'celestial symbol', 'twinkle shape', 'in sky']),
  Word(word: 'diamond', tags: ['four equal sides', 'tilted square', 'gem shape', 'playing card suit', 'rhombus']),
  Word(word: 'heart', tags: ['symbol of love', 'two curves on top', 'point at bottom', 'valentine shape', 'romantic symbol']),
  Word(word: 'hexagon', tags: ['six sides', 'six angles', 'honeycomb shape', 'geometric polygon', 'bee cell']),
  Word(word: 'octagon', tags: ['eight sides', 'eight angles', 'stop sign shape', 'geometric polygon', 'regular shape']),
  
  // Tools
  Word(word: 'hammer', tags: ['hitting tool', 'drives nails', 'has handle', 'metal head', 'construction tool']),
  Word(word: 'screwdriver', tags: ['turns screws', 'has handle', 'flat or phillips', 'hand tool', 'assembly tool']),
  Word(word: 'saw', tags: ['cutting tool', 'has teeth', 'cuts wood', 'sharp blade', 'carpentry tool']),
  Word(word: 'drill', tags: ['makes holes', 'spinning bit', 'power tool', 'electric or manual', 'construction use']),
  Word(word: 'wrench', tags: ['turns bolts', 'adjustable jaw', 'grips nuts', 'plumbing tool', 'mechanic tool']),
  Word(word: 'pliers', tags: ['gripping tool', 'two handles', 'pinches and pulls', 'wire cutter', 'hand tool']),
  Word(word: 'scissors', tags: ['cutting tool', 'two blades', 'opens and closes', 'cuts paper', 'sharp edges']),
  Word(word: 'knife', tags: ['cutting tool', 'sharp blade', 'has handle', 'kitchen utensil', 'slices food']),
  Word(word: 'shovel', tags: ['digging tool', 'has long handle', 'scoops earth', 'garden tool', 'moves dirt']),
  Word(word: 'rake', tags: ['garden tool', 'has teeth', 'gathers leaves', 'long handle', 'yard work']),
  
  // Space
  Word(word: 'moon', tags: ['earths satellite', 'orbits earth', 'reflects sunlight', 'causes tides', 'visible at night']),
  Word(word: 'sun', tags: ['star in center', 'gives light and heat', 'solar system center', 'yellow dwarf star', 'essential for life']),
  Word(word: 'planet', tags: ['orbits sun', 'round celestial body', 'eight in solar system', 'larger than asteroid', 'mars venus earth']),
  Word(word: 'star', tags: ['burning ball of gas', 'twinkles at night', 'very far away', 'produces light', 'millions exist']),
  Word(word: 'galaxy', tags: ['collection of stars', 'milky way example', 'spiral or elliptical', 'billions of stars', 'vast space system']),
  Word(word: 'comet', tags: ['icy space object', 'has tail', 'orbits sun', 'dusty snowball', 'halley famous example']),
  Word(word: 'asteroid', tags: ['space rock', 'orbits sun', 'smaller than planet', 'belt between mars and jupiter', 'can hit earth']),
  Word(word: 'meteor', tags: ['shooting star', 'burns in atmosphere', 'space debris', 'light streak', 'makes wishes']),
  Word(word: 'rocket', tags: ['space vehicle', 'launches to space', 'propulsion system', 'carries astronauts', 'tall and powerful']),
  Word(word: 'astronaut', tags: ['space traveler', 'wears spacesuit', 'works in space', 'trained professional', 'explores cosmos']),
  
  // Drinks
  Word(word: 'water', tags: ['clear liquid', 'essential for life', 'no taste', 'h2o formula', 'most important drink']),
  Word(word: 'coffee', tags: ['caffeinated drink', 'from beans', 'hot beverage', 'morning drink', 'brown liquid']),
  Word(word: 'tea', tags: ['leaf infusion', 'hot or cold', 'many varieties', 'asian origin', 'brewed drink']),
  Word(word: 'juice', tags: ['fruit liquid', 'sweet drink', 'vitamins rich', 'pressed from fruits', 'healthy beverage']),
  Word(word: 'milk', tags: ['white liquid', 'from cows', 'dairy product', 'calcium rich', 'poured on cereal']),
  Word(word: 'soda', tags: ['carbonated drink', 'sweet and fizzy', 'soft drink', 'many flavors', 'sugary beverage']),
  Word(word: 'lemonade', tags: ['lemon drink', 'sweet and sour', 'summer beverage', 'refreshing', 'yellow color']),
  Word(word: 'smoothie', tags: ['blended drink', 'fruit based', 'thick beverage', 'healthy option', 'breakfast drink']),
  Word(word: 'cocoa', tags: ['chocolate drink', 'hot beverage', 'winter comfort', 'made with milk', 'sweet and warm']),
  Word(word: 'wine', tags: ['alcoholic drink', 'from grapes', 'red or white', 'aged in barrels', 'dinner beverage']),
  
  // Flowers
  Word(word: 'rose', tags: ['romantic flower', 'has thorns', 'many colors', 'sweet scent', 'symbol of love']),
  Word(word: 'tulip', tags: ['spring flower', 'cup shaped', 'dutch symbol', 'many colors', 'bulb plant']),
  Word(word: 'sunflower', tags: ['yellow flower', 'faces sun', 'very tall', 'edible seeds', 'bright and cheerful']),
  Word(word: 'daisy', tags: ['simple flower', 'white petals', 'yellow center', 'common wildflower', 'innocent symbol']),
  Word(word: 'lily', tags: ['elegant flower', 'trumpet shaped', 'sweet fragrance', 'white or colored', 'easter flower']),
  Word(word: 'orchid', tags: ['exotic flower', 'delicate beauty', 'many varieties', 'tropical plant', 'elegant bloom']),
  Word(word: 'daffodil', tags: ['spring flower', 'yellow bloom', 'trumpet center', 'early bloomer', 'cheerful flower']),
  Word(word: 'violet', tags: ['small purple flower', 'sweet scent', 'heart shaped leaves', 'woodland plant', 'delicate bloom']),
  Word(word: 'carnation', tags: ['ruffled flower', 'many colors', 'spicy scent', 'long lasting', 'popular cut flower']),
  Word(word: 'marigold', tags: ['orange yellow flower', 'strong scent', 'garden plant', 'pest repellent', 'autumn bloom']),
  
  // Insects
  Word(word: 'bee', tags: ['flying insect', 'makes honey', 'yellow and black', 'pollinates flowers', 'lives in hive']),
  Word(word: 'ant', tags: ['tiny insect', 'lives in colony', 'very strong', 'works in groups', 'six legs']),
  Word(word: 'spider', tags: ['eight legs', 'spins webs', 'catches prey', 'has fangs', 'arachnid not insect']),
  Word(word: 'ladybug', tags: ['small beetle', 'red with spots', 'eats aphids', 'lucky symbol', 'beneficial insect']),
  Word(word: 'dragonfly', tags: ['flying insect', 'four wings', 'lives near water', 'excellent flyer', 'eats mosquitoes']),
  Word(word: 'mosquito', tags: ['biting insect', 'drinks blood', 'buzzing sound', 'spreads disease', 'annoying pest']),
  Word(word: 'grasshopper', tags: ['jumping insect', 'green color', 'long legs', 'chirping sound', 'eats plants']),
  Word(word: 'firefly', tags: ['glowing insect', 'lights at night', 'bioluminescent', 'summer evening', 'lightning bug']),
  Word(word: 'caterpillar', tags: ['larva stage', 'becomes butterfly', 'many legs', 'eats leaves', 'worm like']),
  Word(word: 'beetle', tags: ['hard shell insect', 'many varieties', 'six legs', 'strong armor', 'diverse group']),
  
  // Trees
  Word(word: 'oak', tags: ['strong tree', 'produces acorns', 'broad leaves', 'long lived', 'deciduous tree']),
  Word(word: 'pine', tags: ['evergreen tree', 'needle leaves', 'produces cones', 'stays green year round', 'christmas tree']),
  Word(word: 'maple', tags: ['leaf tree', 'makes syrup', 'beautiful fall colors', 'canadian symbol', 'deciduous tree']),
  Word(word: 'palm', tags: ['tropical tree', 'long fronds', 'no branches', 'beach tree', 'coconuts grow here']),
  Word(word: 'willow', tags: ['drooping branches', 'grows near water', 'graceful tree', 'weeping variety', 'flexible wood']),
  Word(word: 'birch', tags: ['white bark', 'paper like bark', 'thin trunk', 'northern tree', 'peels in layers']),
  Word(word: 'cherry', tags: ['fruit tree', 'pink blossoms', 'springtime beauty', 'produces cherries', 'ornamental tree']),
  Word(word: 'redwood', tags: ['giant tree', 'tallest species', 'california native', 'very old', 'massive trunk']),
  Word(word: 'bamboo', tags: ['fast growing', 'hollow stems', 'asian plant', 'panda food', 'strong and flexible']),
  Word(word: 'cypress', tags: ['swamp tree', 'coniferous tree', 'distinctive knees', 'grows in water', 'southern tree']),
  
  // Hobbies
  Word(word: 'reading', tags: ['enjoying books', 'leisure activity', 'learning hobby', 'quiet pastime', 'imagination builder']),
  Word(word: 'painting', tags: ['creating art', 'using colors', 'canvas hobby', 'creative expression', 'visual art']),
  Word(word: 'gardening', tags: ['growing plants', 'outdoor hobby', 'planting flowers', 'nurturing nature', 'green thumb']),
  Word(word: 'cooking', tags: ['preparing food', 'culinary hobby', 'making meals', 'kitchen activity', 'recipe following']),
  Word(word: 'photography', tags: ['taking pictures', 'camera hobby', 'capturing moments', 'artistic pursuit', 'visual storytelling']),
  Word(word: 'dancing', tags: ['moving to music', 'rhythmic activity', 'expressive art', 'many styles', 'performance hobby']),
  Word(word: 'fishing', tags: ['catching fish', 'outdoor activity', 'patient hobby', 'rod and reel', 'relaxing pastime']),
  Word(word: 'knitting', tags: ['making fabric', 'using needles', 'yarn craft', 'making clothes', 'relaxing hobby']),
  Word(word: 'hiking', tags: ['walking trails', 'outdoor exercise', 'nature activity', 'mountain climbing', 'exploring paths']),
  Word(word: 'collecting', tags: ['gathering items', 'building collection', 'hobby pursuit', 'organizing treasures', 'stamps coins cards']),
  
  // Months
  Word(word: 'january', tags: ['first month', 'new year month', 'winter month', 'cold season', '31 days']),
  Word(word: 'february', tags: ['second month', 'shortest month', 'valentines month', '28 or 29 days', 'winter month']),
  Word(word: 'march', tags: ['third month', 'spring begins', 'windy month', '31 days', 'st patricks']),
  Word(word: 'april', tags: ['fourth month', 'spring month', 'showers bring flowers', '30 days', 'easter month']),
  Word(word: 'may', tags: ['fifth month', 'spring month', 'flowers bloom', '31 days', 'mothers day']),
  Word(word: 'june', tags: ['sixth month', 'summer begins', 'warm weather', '30 days', 'wedding month']),
  Word(word: 'july', tags: ['seventh month', 'summer month', 'hot weather', '31 days', 'independence day']),
  Word(word: 'august', tags: ['eighth month', 'summer month', 'vacation time', '31 days', 'hot season']),
  Word(word: 'september', tags: ['ninth month', 'autumn begins', 'school starts', '30 days', 'fall month']),
  Word(word: 'october', tags: ['tenth month', 'autumn month', 'halloween month', '31 days', 'fall colors']),
  Word(word: 'november', tags: ['eleventh month', 'autumn month', 'thanksgiving month', '30 days', 'getting colder']),
  Word(word: 'december', tags: ['twelfth month', 'winter begins', 'holiday month', '31 days', 'christmas time']),
  
  // Days of Week
  Word(word: 'monday', tags: ['first weekday', 'start of work week', 'after weekend', 'back to school', 'beginning']),
  Word(word: 'tuesday', tags: ['second weekday', 'middle week', 'taco tuesday', 'working day', 'midweek approaching']),
  Word(word: 'wednesday', tags: ['middle of week', 'hump day', 'halfway point', 'working day', 'midweek']),
  Word(word: 'thursday', tags: ['fourth weekday', 'almost friday', 'working day', 'thors day', 'near weekend']),
  Word(word: 'friday', tags: ['last weekday', 'casual day', 'weekend approaching', 'celebration day', 'relief day']),
  Word(word: 'saturday', tags: ['weekend day', 'no work or school', 'fun day', 'sleeping in', 'free time']),
  Word(word: 'sunday', tags: ['weekend day', 'rest day', 'family day', 'last before monday', 'relaxation']),
  
  // Seasons
  Word(word: 'spring', tags: ['season of renewal', 'flowers bloom', 'after winter', 'warmer weather', 'march to june']),
  Word(word: 'summer', tags: ['hottest season', 'vacation time', 'longest days', 'june to september', 'beach weather']),
  Word(word: 'autumn', tags: ['fall season', 'leaves change color', 'harvest time', 'september to december', 'getting cooler']),
  Word(word: 'winter', tags: ['coldest season', 'snow season', 'shortest days', 'december to march', 'holiday time']),
  
  // Numbers & Math
  Word(word: 'addition', tags: ['math operation', 'plus symbol', 'combining numbers', 'sum result', 'increasing total']),
  Word(word: 'subtraction', tags: ['math operation', 'minus symbol', 'taking away', 'difference result', 'decreasing']),
  Word(word: 'multiplication', tags: ['math operation', 'times symbol', 'repeated addition', 'product result', 'scaling up']),
  Word(word: 'division', tags: ['math operation', 'divide symbol', 'splitting up', 'quotient result', 'sharing equally']),
  Word(word: 'fraction', tags: ['part of whole', 'numerator and denominator', 'ratio representation', 'divided number', 'slice portion']),
  Word(word: 'decimal', tags: ['number with point', 'fractional notation', 'base ten system', 'precise value', 'partial number']),
  Word(word: 'percentage', tags: ['out of hundred', 'ratio format', 'proportion', 'parts per hundred', 'percent sign']),
  
  // Metals & Materials
  Word(word: 'gold', tags: ['precious metal', 'yellow color', 'valuable', 'jewelry material', 'chemical element']),
  Word(word: 'silver', tags: ['precious metal', 'shiny white', 'conductive', 'jewelry and coins', 'second place medal']),
  Word(word: 'iron', tags: ['common metal', 'strong material', 'rusts easily', 'magnetic property', 'steel ingredient']),
  Word(word: 'copper', tags: ['reddish metal', 'good conductor', 'penny material', 'electrical wires', 'ancient metal']),
  Word(word: 'wood', tags: ['natural material', 'from trees', 'construction material', 'burns as fuel', 'furniture making']),
  Word(word: 'glass', tags: ['transparent material', 'fragile substance', 'made from sand', 'window material', 'smooth surface']),
  Word(word: 'plastic', tags: ['synthetic material', 'moldable substance', 'petroleum based', 'many forms', 'modern material']),
  Word(word: 'stone', tags: ['rock material', 'hard substance', 'natural resource', 'building material', 'sculpting medium']),
  Word(word: 'paper', tags: ['thin material', 'from wood pulp', 'writing surface', 'printable', 'recyclable']),
  Word(word: 'fabric', tags: ['cloth material', 'woven threads', 'textile', 'clothing material', 'many types']),
];

class WordsService {
  List<Word> getAllWords() {
    return words;
  }

  Word getRandomWord() {
    final random = words.toList()..shuffle();
    return random.first;
  }

  List<Word> searchByTag(String tag) {
    return words.where((word) => 
      word.tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()))
    ).toList();
  }

  List<Word> getWordsByDifficulty(int minLength, int maxLength) {
    return words.where((word) => 
      word.word.length >= minLength && word.word.length <= maxLength
    ).toList();
  }
}
