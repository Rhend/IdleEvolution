# ============================================================
# CombatLoadingScreen — écran de chargement affiché à l'ouverture d'un combat
# CTB (retour Rhend 07/09/2026 : « trop de temps à charger »).
#
# `CombatCtbUi._construire()` monte en un seul bloc SYNCHRONE le décor de
# ville parallaxé (12 calques, plusieurs copies pour le ruban défilant) et le
# sprite Spine du héros (chargement skel/atlas + mesure de silhouette) —
# assez long pour figer une frame ou deux. `_ready()` étant appelé de façon
# synchrone par `add_child()`, RIEN ne se redessine pendant ce temps : sans
# cet écran, le joueur voit la carte d'expédition rester gelée jusqu'à ce que
# le combat apparaisse d'un coup.
#
# Posé et laissé peindre AU MOINS une frame par l'appelant (voir
# `ExpeditionScreen._traiter_combat` / `SandboxExpe._traiter_combat`) AVANT
# de construire `CombatCtbUi`, puis libéré juste après : le splash « ENNEMY
# DETECTED » de `CombatCtbUi._intro()` est déjà construit à ce moment (son
# unique `await` est plus loin dans la fonction), donc rien ne clignote au
# retrait — c'est la même image, `CombatUiSkin.splash_ennemi_detecte()`,
# jamais une seconde copie.
# ============================================================
class_name CombatLoadingScreen
extends Control

static func afficher(parent: Control) -> CombatLoadingScreen:
	var ecran := CombatLoadingScreen.new()
	ecran.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ecran.mouse_filter = Control.MOUSE_FILTER_STOP
	var fond := ColorRect.new()
	fond.color = Color(0, 0, 0, 1)
	fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ecran.add_child(fond)
	ecran.add_child(CombatUiSkin.splash_ennemi_detecte())
	parent.add_child(ecran)
	return ecran
