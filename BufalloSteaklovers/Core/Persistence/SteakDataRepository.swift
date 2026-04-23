//
//  SteakDataRepository.swift
//  BufalloSteaklovers
//

import Foundation

final class SteakDataRepository: ObservableObject {
    private let defaultsKey = "steak.sessions.v1"

    @Published private(set) var sessions: [PersistedSteakSession] = []

    init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            sessions = []
            return
        }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        sessions = (try? dec.decode([PersistedSteakSession].self, from: data)) ?? []
    }

    private func persist() {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.sortedKeys]
        if let data = try? enc.encode(sessions) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    func add(_ session: PersistedSteakSession) {
        var next = sessions
        next.append(session)
        sessions = next
        persist()
    }

    func updateResolved(failureId: UUID, resolved: Bool) {
        guard let i = sessions.firstIndex(where: { $0.id == failureId }) else { return }
        var next = sessions
        next[i].failureResolved = resolved
        sessions = next
        persist()
    }

    func remove(id: UUID) {
        if let s = sessions.first(where: { $0.id == id }), let fn = s.photoFilename {
            PhotoFileStore.deleteImage(filename: fn)
        }
        sessions = sessions.filter { $0.id != id }
        persist()
    }
}
