import Foundation

extension ToolContractCompiler {
    public init(seeds: [C5SemanticSeed], dDomainCatalog: [DDomainToolEntry] = []) {
        func unique(_ values: [String]) -> [String] {
            Array(Set(values.filter { !$0.isEmpty })).sorted()
        }

        self.devices = unique(seeds.map(\.device))
        self.actionPrimitives = unique(seeds.map(\.actionPrimitive))
        self.valueTypes = unique(seeds.map { $0.value.type })
        self.slotKeys = unique(seeds.flatMap(\.slotKeys))
        self.dDomainCatalog = dDomainCatalog
    }
}
