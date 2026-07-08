import CryptoKit
import Foundation

public enum C6Hash {
    public static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func fileHash(url: URL) throws -> String {
        sha256Hex(try Data(contentsOf: url))
    }

    public static func contractDigest(repoRoot: URL, datasetText: String) throws -> String {
        var data = Data()
        for path in [
            "contracts/semantic-function-contract.jsonl",
            "contracts/state-cells.yaml",
            "contracts/c6-bench-cases.jsonl",
            "contracts/qwen-tool-call-format.yaml",
            "generated/d_domain_ir_map.json"   // S5: D-domain 名→IR 映射是 bench 行为依赖, 纳入指纹防 stale gate 失守
        ] {
            if path == "contracts/c6-bench-cases.jsonl" {
                data.append(Data(datasetText.utf8))
            } else {
                data.append(try Data(contentsOf: repoRoot.appendingPathComponent(path)))
            }
        }
        return sha256Hex(data)
    }
}
