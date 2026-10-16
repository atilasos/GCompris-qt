// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'ColorsHelpNavigationAndMenu'
    when: activity.visible && items.numberOfLevel>0
    property var vocabulary: {"Descobrir a borboleta cor de coral": "coral_butterfly.svg", "Descobrir a borboleta cor de clarete": "claret_butterfly.svg", "Descobrir a borboleta azul-marinha": "navy_butterfly.svg", "Descobrir a borboleta cor de milho": "corn_butterfly.svg", "Descobrir a borboleta cobalto": "cobalt_butterfly.svg", "Descobrir a borboleta cíana": "cyan_butterfly.svg", "Descobrir a borboleta cor-de-castanha": "chestnut_butterfly.svg", "Descobrir a borboleta cor de amêndoa": "almond_butterfly.svg", "Descobrir a borboleta safira": "sapphire_butterfly.svg", "Descobrir a borboleta rubi": "ruby_butterfly.svg", "Descobrir a borboleta cor de terra": "sienna_butterfly.svg", "Descobrir a borboleta cor de salva": "sage_butterfly.svg", "Descobrir a borboleta cor de salmão": "salmon_butterfly.svg", "Descobrir a borboleta sépia": "sepia_butterfly.svg", "Descobrir a borboleta cor de enxofre": "sulphur_butterfly.svg", "Descobrir a borboleta cor-de-chá": "tea_butterfly.svg", "Descobrir a borboleta verde-lima": "lime_butterfly.svg", "Descobrir a borboleta azul-turquesa": "turquoise_butterfly.svg", "Descobrir a borboleta cor de absinto": "absinthe_butterfly.svg", "Descobrir a borboleta cor de mogno": "mahogany_butterfly.svg", "Descobrir a borboleta aquamarinha": "aquamarine_butterfly.svg", "Descobrir a borboleta cor de alabastro": "alabaster_butterfly.svg", "Descobrir a borboleta âmbar": "amber_butterfly.svg", "Descobrir a borboleta cor de ametista": "amethyst_butterfly.svg", "Descobrir a borboleta cor-de-anis": "anise_butterfly.svg", "Descobrir a borboleta sanguínea": "vermilion_butterfly.svg", "Descobrir a borboleta cor de pó-de-arroz": "ceruse_butterfly.svg", "Descobrir a borboleta amarela-esverdeada": "chartreuse_butterfly.svg", "Descobrir a borboleta esmeralda": "emerald_butterfly.svg", "Descobrir a borboleta cor de beringela": "aubergine_butterfly.svg", "Descobrir a borboleta fúcsia": "fuchsia_butterfly.svg", "Descobrir a borboleta cor azul-cinza": "glaucous_butterfly.svg", "Descobrir a borboleta ruiva": "auburn_butterfly.svg", "Descobrir a borboleta azulão": "azure_butterfly.svg", "Descobrir a borboleta acastanhada": "greyish-brown_butterfly.svg", "Descobrir a borboleta castanha-escura": "bistre_butterfly.svg", "Descobrir a borboleta carmim": "crimson_butterfly.svg", "Descobrir a borboleta cor de porcelana": "celadon_butterfly.svg", "Descobrir a borboleta cerúlea": "cerulean_butterfly.svg", "Descobrir a borboleta cor-de-pomba": "dove_butterfly.svg", "Descobrir a borboleta grená": "garnet_butterfly.svg", "Descobrir a borboleta índigo": "indigo_butterfly.svg", "Descobrir a borboleta marfim": "ivory_butterfly.svg", "Descobrir a borboleta jade": "jade_butterfly.svg", "Descobrir a borboleta alfazema": "lavender_butterfly.svg", "Descobrir a borboleta cor-de-líquen": "lichen_butterfly.svg", "Descobrir a borboleta cor de vinho": "wine_butterfly.svg", "Descobrir a borboleta lilás": "lilac_butterfly.svg", "Descobrir a borboleta magenta": "magenta_butterfly.svg", "Descobrir a borboleta malaquite": "malachite_butterfly.svg", "Descobrir a borboleta cor de pinho": "larch_butterfly.svg", "Descobrir a borboleta cor de mimosas": "mimosa_butterfly.svg", "Descobrir a borboleta ocre": "ochre_butterfly.svg", "Descobrir a borboleta verde-azeitona": "olive_butterfly.svg", "Descobrir a borboleta opala": "opaline_butterfly.svg", "Descobrir a borboleta ultramarina": "ultramarine_butterfly.svg", "Descobrir a borboleta cor de malva": "mauve_butterfly.svg", "Descobrir a borboleta azul-parda": "greyish_blue_butterfly.svg", "Descobrir a borboleta cor de pistacho": "pistachio_butterfly.svg", "Descobrir a borboleta platinada": "platinum_butterfly.svg", "Descobrir a borboleta púrpura": "purple_butterfly.svg", "Descobrir a borboleta de ameixa": "plum_butterfly.svg", "Descobrir a borboleta azul-da-prússia": "prussian_blue_butterfly.svg", "Descobrir a borboleta cor de ferrugem": "rust_butterfly.svg", "Descobrir a borboleta cor de açafrão": "saffron_butterfly.svg", "Descobrir a borboleta cor de baunilha": "vanilla_butterfly.svg", "Descobrir a borboleta veronesa": "veronese_butterfly.svg", "Descobrir a borboleta cor de verdete": "verdigris_butterfly.svg", "Descobrir a borboleta púrpura-escura": "dark_purple_butterfly.svg", "Descobrir a borboleta fulva": "fawn_butterfly.svg"}
    property var evidence: ({})
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var found=find(child,predicate);if(found)return found;}return null;}
    function click(item){verify(item!==null);var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);wait(200);}
    function button(suffix){click(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix);}));}
    function test_controls(){
        wait(1800);compare(activity.activityInfo.title,"Cores avançadas");compare(items.numberOfLevel,20);
        verify(find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith('bar_activity_config.svg');})===null,'No local configuration is exposed');
        if(false){
            var plus=find(color1,function(item){return item.source!==undefined&&String(item.source).endsWith('plus.svg')&&item.buttonsBlocked!==undefined;});
            click(plus);verify(String(result.color)!==String(activity.modeRGB?'#000000':'#ffffff'));
        }else{
            tryCompare(instructionPanel,'opacity',1,4000);tryCompare(items,'objectSelected',false,4000);
            var wanted=vocabulary[String(instructionPanel.textItem.text)],correct=null;
            for(var i=0;i<container.count;i++){var option=container.itemAtIndex(i);if(String(option.source).endsWith('/'+wanted))correct=option;}
            verify(correct!==null);activityBackground.forceActiveFocus();
            for(var turn=0;turn<container.count+1&&container.currentItem!==correct;turn++)keyClick(Qt.Key_Right);
            compare(container.currentItem,correct);keyClick(Qt.Key_Space);compare(score.currentSubLevel,1);wait(1200);
        }
        button('bar_next.svg');compare(items.currentLevel,1);compare(score.currentSubLevel,0);
        button('bar_previous.svg');compare(items.currentLevel,0);compare(score.currentSubLevel,0);wait(800);
        if(false)compare(String(result.color),activity.modeRGB?'#000000':'#ffffff');
        var depth=pageView.depth;button('bar_help.svg');tryCompare(pageView,'depth',depth+1,3000);wait(800);
        var help=pageView.currentItem;compare(help.title,"Cores avançadas");
        verify(help.content.indexOf(activity.activityInfo.manual)>=0);verify(activity.activityInfo.manual.length>20);
        verify(help.content.indexOf('This activity')<0&&help.content.indexOf('Click on')<0);
        grabImage(pageView).save('__QA_OUTPUT__/help.png');
        click(find(help,function(item){return item.source!==undefined&&String(item.source).endsWith('cancel.svg');}));
        tryCompare(pageView,'depth',depth,3000);wait(800);
        if(false){
            var old=String(result.color);click(plus);verify(String(result.color)!==old,'Controls work after help');
        }else{
            var oldIndex=container.currentIndex;keyClick(Qt.Key_Right);verify(container.currentIndex!==oldIndex,'Keyboard focus restored after help');
        }
        ActivityInfoTree.startingActivity='';
        if(true)keyClick(Qt.Key_Escape);else button('bar_home.svg');
        tryCompare(pageView,'depth',1,3000);verify(pageView.currentItem.isMenu);
        evidence={title:"Cores avançadas",helpPortuguese:true,localConfigurationAbsent:true,partialRestart:true,previousNext:true,inputAfterHelp:true,exit:true?'Escape':'Home',menu:true};
    }
    function cleanupTestCase(){console.log('NATIVE_COLORS_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
