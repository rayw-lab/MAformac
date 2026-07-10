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

if __name__ == '__main__': unittest.main()
