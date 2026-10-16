# SPDX-License-Identifier: GPL-3.0-or-later
"""Historical phases and observed case roles, without relabelling raw receipts."""
PHASES={'baseline':'8aeb434c79ae933a881a70228297cf9467fbab1f','canal-words':'045ff0d763ff89c9ebd6fcb849d11d4495f0b6c7','water-words':'58e67c399e4de26d84d02d3d43080a488ed6b9cd'}
FILES={'canal_lock':'CanalLock.qml','watercycle':'Watercycle.qml','renewable_energy':'RenewableEnergy.qml'}
CASES={
 'wording-canal-red':{'activity':'canal_lock','phase':'baseline','kind':'wording-red','expected_exit':1},
 'wording-canal-green':{'activity':'canal_lock','phase':'canal-words','kind':'wording-green'},
 'wording-water-red':{'activity':'watercycle','phase':'canal-words','kind':'wording-red','expected_exit':1},
 'wording-water-green':{'activity':'watercycle','phase':'water-words','kind':'wording-green'},
 'canal-complete2':{'activity':'canal_lock','phase':'canal-words','kind':'gameplay'},
 'water-pilot':{'activity':'watercycle','phase':'canal-words','kind':'gameplay'},
 'energy-pilot':{'activity':'renewable_energy','phase':'canal-words','kind':'gameplay'},
}
for activity,name in [('canal_lock','canal'),('watercycle','water'),('renewable_energy','energy')]:
 CASES['controls-'+name+'2']={'activity':activity,'phase':'water-words','kind':'controls'}
 CASES['resources-'+activity]={'activity':activity,'phase':'water-words','kind':'resources'}
 CASES['controls-'+name]={'activity':activity,'phase':'water-words','kind':'fixture-diagnostic','expected_exit':1}
for name in ['canal-complete','canal-diagnostic']:CASES[name]={'activity':'canal_lock','phase':'canal-words','kind':'fixture-diagnostic','expected_exit':1}
PAIRS=[('wording-canal-red','wording-canal-green'),('wording-water-red','wording-water-green')]
