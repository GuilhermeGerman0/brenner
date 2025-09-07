async function deletarPorId(execQuery, tipo, id) {
    const tablatura = await execQuery(`select * from brenner.Tablaturas where id${tipo} = ${id}`)
    if (tablatura.length > 0) {
        await execQuery(`delete from brenner.Tablaturas where id${tipo} = ${id}`)
    }
    const result = await execQuery(`delete from brenner.${tipo}s where id${tipo} = ${id}`)
    return result
}

async function deletarPorNome(execQuery, tipo, nomeCampo, nome) {
    const entidade = await execQuery(`select id${tipo} from brenner.${tipo}s where ${nomeCampo} = '${nome}'`)
    if (!entidade[0]) return null
    const id = entidade[0][`id${tipo}`]
    const tablatura = await execQuery(`select * from brenner.Tablaturas where id${tipo} = ${id}`)
    if (tablatura.length > 0) {
        await execQuery(`delete from brenner.Tablaturas where id${tipo} = ${id}`)
    }
    const result = await execQuery(`delete from brenner.${tipo}s where id${tipo} = ${id}`)
    return result
}

module.exports = { deletarPorId, deletarPorNome }