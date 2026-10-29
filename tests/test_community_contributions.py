#!/usr/bin/env python3
import json, pathlib, re, subprocess, unittest, xml.etree.ElementTree as ET
root = pathlib.Path(__file__).resolve().parents[1]
class CommunityContributions(unittest.TestCase):
    def test_logos_and_saved_indices(self):
        code = (root / 'plasmoid/contents/code/code.js').read_text()
        script = code.replace('.pragma library', '') + '''\nif (logos.slice(0,23).join(',') !== 'tux,slackware,ubuntu,kubuntu,opensuse,manjaro,arch,fedora,debian,linuxmint,endeavouros,pop,zorin,elementary,nixos,gentoo,alpine,void,rocky,almalinux,rhel,centos,kali') throw Error('saved indices changed');
for (const [id, key] of [[24,'blackpanther'],[25,'neon']]) { if (logoFile(id, '') !== 'distro-'+key+'.svg' || detectDistro([key]) !== key) throw Error(key); }'''
        subprocess.run(['node', '-e', script], check=True)
        ns = {'k':'http://www.kde.org/standards/kcfg/1.0'}
        choices = ET.parse(root / 'plasmoid/contents/config/main.xml').find(".//k:entry[@name='logo']/k:choices",ns)
        self.assertEqual([x.attrib['name'] for x in choices][-3:], ['blackPanther OS','KDE neon','Custom'])
        for name in ('blackpanther','neon','kubuntu'):
            ET.parse(root / ('plasmoid/contents/images/distro-'+name+'.svg'))
    def test_all_logo_assets_are_self_contained_vectors(self):
        code = (root / 'plasmoid/contents/code/code.js').read_text()
        names = re.findall(r'"([^"]+)"', re.search(r'var logos = \[(.*?)\]', code, re.S).group(1))
        for name in names:
            with self.subTest(name=name):
                svg = ET.parse(root / ('plasmoid/contents/images/distro-' + name + '.svg')).getroot()
                self.assertTrue(svg.get('viewBox') or (svg.get('width') and svg.get('height')))
                for element in svg.iter():
                    self.assertNotEqual(element.tag.rsplit('}', 1)[-1], 'image')
                    for attr, value in element.attrib.items():
                        if attr.rsplit('}', 1)[-1] == 'href':
                            self.assertTrue(value.startswith('#'), value)

    def test_hungarian_metadata_and_catalogue(self):
        metadata=json.loads((root / 'plasmoid/metadata.json').read_text())['KPlugin']
        self.assertTrue(metadata['Name[hu]'] and metadata['Description[hu]'])
        po=root / 'translations/hu/LC_MESSAGES/plasma_applet_org.kde.simpleMonitor.po'
        subprocess.run(['msgfmt','--check','-o','/dev/null',str(po)],check=True)
        self.assertIn('msgstr "Általános"',po.read_text())
if __name__ == '__main__': unittest.main()
