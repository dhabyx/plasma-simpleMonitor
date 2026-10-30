#!/usr/bin/env python3
import pathlib, unittest, xml.etree.ElementTree as ET
root=pathlib.Path(__file__).resolve().parents[1]
ns={'k':'http://www.kde.org/standards/kcfg/1.0'}
class SettingsSchema(unittest.TestCase):
    def test_new_defaults_preserve_existing_layout(self):
        schema=ET.parse(root/'plasmoid/contents/config/main.xml')
        for name, default in {'autoFitContent':'false','showLogo':'true','showCpuFrequency':'false','compactLayout':'false','dateVisibility':'0','timeVisibility':'0','cpuColumns':'1','showDistroName':'true','showDistroVersion':'true','showDistroCodename':'true','distroLayout':'0'}.items():
            with self.subTest(name=name):
                item=schema.find(".//k:entry[@name='%s']"%name,ns)
                self.assertIsNotNone(item)
                self.assertEqual(item.find('k:default',ns).text,default)
    def test_stored_indices_remain_unchanged(self):
        schema=ET.parse(root/'plasmoid/contents/config/main.xml')
        for name, count, last in [('skin',3,'Minimalistic'),('logo',27,'Custom')]:
            choices=schema.findall(".//k:entry[@name='%s']/k:choices/k:choice"%name,ns)
            self.assertEqual(len(choices),count)
            self.assertEqual(choices[-1].get('name'),last)
if __name__=='__main__': unittest.main()
