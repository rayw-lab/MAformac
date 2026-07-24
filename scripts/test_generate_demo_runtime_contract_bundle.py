import json, tempfile, unittest
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parents[1] / 'Tools'))
from generate_demo_runtime_contract_bundle import SelectionError, SemanticSelection, select_semantic_rows, generate

class BundleGeneratorTests(unittest.TestCase):
    def setUp(self):
        self.rows = [{"contract_row_id":"r1","source_row_hash":"a"*64,"canonical_semantic_id":"sem_1111111111111111"}, {"contract_row_id":"r2","source_row_hash":"b"*64,"canonical_semantic_id":"sem_2222222222222222"}]
    def test_exact_composite_identity(self):
        out = select_semantic_rows(self.rows, [SemanticSelection('r2','b'*64,'sem_2222222222222222','u')])
        self.assertEqual(out, [self.rows[1]])
    def test_partial_and_cross_record_fail_closed(self):
        for s in [SemanticSelection('r1','b'*64,'sem_1111111111111111','u'), SemanticSelection('r1','a'*64,'sem_2222222222222222','u')]:
            with self.assertRaises(SelectionError): select_semantic_rows(self.rows, [s])
    def test_duplicate_runtime_use_fails(self):
        with self.assertRaises(SelectionError): select_semantic_rows(self.rows, [SemanticSelection('r1','a'*64,'sem_1111111111111111','u'), SemanticSelection('r2','b'*64,'sem_2222222222222222','u')])
    def test_real_generation_has_distinct_versions_and_digest(self):
        manifest, digest = generate(Path(__file__).parents[1])
        self.assertEqual(manifest['runtime_contract_bundle_digest'], digest)
        self.assertNotEqual(manifest['schema_version'], manifest['catalog_schema_version'])
        self.assertEqual(len(digest), 64)

    def test_row000021_triple_identity_and_semantic_slots(self):
        """Lock row000021 (c1_carControl_000021) triple identity and key semantic fields.
        Prevents accidental selection of row000013 or 000010 which have different
        ref/type/position slot characteristics."""
        manifest, _ = generate(Path(__file__).parents[1])
        rows = manifest['selected_semantic_rows']
        row021 = [r for r in rows if r['contract_row_id'] == 'c1_carControl_000021']
        self.assertEqual(len(row021), 1, "row000021 must be in selected set")
        r = row021[0]
        # Triple identity
        self.assertEqual(r['contract_row_id'], 'c1_carControl_000021')
        self.assertEqual(r['source_row_hash'], 'b7daab138f29afa91a896727762461eba97133b4cc5b5eac6d07d42a509307aa')
        self.assertEqual(r['canonical_semantic_id'], 'sem_9f55d735f0de20e0')
        # Key semantic slot fields: ref=CUR, type=PERCENT, has position
        ds = r['ds_protocol']
        self.assertEqual(ds['intent'], 'open_window_by_number')
        self.assertEqual(ds['service'], 'carControl')
        slots = ds['semantic']['slots']
        self.assertIn('position', slots, "row000021 must have position slot (distinguishes from 000010)")
        self.assertEqual(slots['value']['ref'], 'CUR', "row000021 must use ref=CUR (distinguishes from 000013 which uses ZERO)")
        self.assertEqual(slots['value']['type'], 'PERCENT', "row000021 must use type=PERCENT")
        self.assertEqual(slots['value']['direct'], '+')

    def test_phase2_ambient_and_seat_rows_keep_exact_identity(self):
        manifest, _ = generate(Path(__file__).parents[1])
        rows = {row['contract_row_id']: row for row in manifest['selected_semantic_rows']}
        expected = {
            'c1_carControl_001972': (
                '4481309392881ac4770fe6bcc4d02c6610c5e18075e34f04b2a01d28933af9fb',
                'sem_3d2bf62beb619a73',
                'open_atmosphere_lamp',
                {},
            ),
            'c1_carControl_000201': (
                '7cf33c3abe4d5170c2309205ced88d18d6d5afe1aff2a388f467eaaabe5cbc80',
                'sem_5c562bb80d48eb10',
                'open_seat_heat',
                {'position': '<座椅位置>'},
            ),
        }
        for row_id, (source_hash, semantic_id, intent, slots) in expected.items():
            row = rows[row_id]
            self.assertEqual(row['source_row_hash'], source_hash)
            self.assertEqual(row['canonical_semantic_id'], semantic_id)
            self.assertEqual(row['ds_protocol']['intent'], intent)
            self.assertEqual(row['ds_protocol']['service'], 'carControl')
            self.assertEqual(row['ds_protocol']['semantic']['slots'], slots)

if __name__ == '__main__': unittest.main()
