# ============================================================
# AssetCache — cache mémoire, pour la durée de la session, des ressources
# lourdes rechargées à CHAQUE combat (retour Rhend 07/09/2026 : « trop de
# temps à charger »).
#
# Le décor de ville/usine (CombatDecorCity/CombatDecorFactory, jusqu'à
# ~12 calques chacun, certains 4770×2655 px) et le squelette Spine du héros
# (SpriteSpinePersonnage) sont rechargés depuis le disque à CHAQUE ouverture
# d'écran de combat : `load()` seul ne suffit pas à éviter ce coût, car ses
# Resource (Texture2D, skel/atlas Spine) n'ont plus aucune référence vivante
# une fois le CombatCtbUi précédent libéré (`queue_free`) — Godot les décharge
# et le combat suivant repaie intégralement le chargement + décodage.
#
# En gardant une référence ici (class_name statique, PAS un autoload — même
# pattern que Balance/ExpeStyle : l'état vit dans une `static var`, partagée
# par tous les appelants sans passer par l'arbre de scène), le coût n'est payé
# qu'UNE fois par fichier pour toute la session — y compris entre un combat et
# la ShowRoom, qui charge les mêmes squelettes.
#
# ⚠ Ne cache QUE des Resource immuables une fois chargées (textures, données
# Spine) : partager la MÊME instance entre plusieurs SpineSprite est le
# fonctionnement normal du runtime Spine (skeleton data = définition
# partagée, la pose vit dans le SpineSprite/AnimationState de chacun), pas un
# hack. Un rechargement à chaud d'un asset modifié sur le disque en pleine
# session ne sera vu qu'au prochain lancement du jeu — déjà le cas pour toute
# ressource gardée en mémoire ailleurs dans le projet.
# ============================================================
class_name AssetCache

static var _ressources: Dictionary = {}

static func charger(chemin: String) -> Resource:
	if _ressources.has(chemin):
		return _ressources[chemin]
	if not ResourceLoader.exists(chemin):
		return null
	var ressource := load(chemin)
	if ressource != null:
		_ressources[chemin] = ressource
	return ressource
