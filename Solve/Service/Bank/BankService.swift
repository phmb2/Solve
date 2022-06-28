//
//  BankService.swift
//  Solve
//
//  Created by Pedro Barbosa on 12/01/22.
//

import Foundation

struct BankService {
    static let shared = BankService()
    
    var banks: [Bank] = [
        Bank(code: "246", name: "Banco ABC Brasil S.A.", url: "https://www.abcbrasil.com.br"),
        Bank(code: "748", name: "Banco Cooperativo Sicredi S.A.", url: "https://www.sicredi.com.br"),
        Bank(code: "237", name: "Banco Bradesco S.A.", url: "https://banco.bradesco"),
        Bank(code: "218", name: "Banco BS2 S.A.", url: "https://www.bancobs2.com.br"),
        Bank(code: "208", name: "Banco BTG Pactual S.A.", url: "https://www.btgpactual.com"),
        Bank(code: "336", name: "Banco C6 S.A – C6 Bank", url: "https://www.c6bank.com.br"),
        Bank(code: "473", name: "Banco Caixa Geral – Brasil S.A.", url: "https://www.caixa.gov.br"),
        Bank(code: "069", name: "Banco Crefisa S.A.", url: "https://www.crefisamais.com.br"),
        Bank(code: "001", name: "Banco do Brasil S.A.", url: "https://www.bb.com.br"),
        Bank(code: "004", name: "Banco do Nordeste do Brasil S.A.", url: "https://www.bnb.gov.br"),
        Bank(code: "077", name: "Banco Inter S.A.", url: "https://bancointer.com.br"),
        Bank(code: "184", name: "Banco Itaú BBA S.A.", url: "https://www.itau.com.br"),
        Bank(code: "746", name: "Banco Modal S.A.", url: "https://www.modal.com.br"),
        Bank(code: "212", name: "Banco Original S.A.", url: "https://www.original.com.br"),
        Bank(code: "623", name: "Banco PAN S.A.", url: "https://www.bancopan.com.br"),
        Bank(code: "422", name: "Banco Safra S.A.", url: "https://www.bancosafra.com.br"),
        Bank(code: "033", name: "Banco Santander (Brasil) S.A.", url: "https://www.santander.com.br"),
        Bank(code: "104", name: "Caixa Econômica Federal", url: "https://www.safra.com.br"),
        Bank(code: "341", name: "Itaú Unibanco S.A.", url: "https://www.itau.com.br"),
        Bank(code: "260", name: "Nu Pagamentos S.A (Nubank)", url: "https://www.nubank.com.br"),
        Bank(code: "254", name: "Paraná Banco S.A.", url: "https://www.paranabanco.com.br"),
        Bank(code: "102", name: "XP Investimentos S.A", url: "https://www.xpi.com.br"),
        Bank(code: "335", name: "Banco Digio S.A", url: "https://www.digio.com.br"),
        Bank(code: "318", name: "Banco BMG S.A.", url: "https://www.bancobmg.com.br"),
        Bank(code: "121", name: "Banco Agibank S.A.", url: "https://www.agibank.com.br"),
        Bank(code: "188", name: "Ativa Investimentos S.A", url: "https://www.ativainvestimentos.com.br"),
        Bank(code: "290", name: "Pagseguro Internet S.A (PagBank)", url: "https://pagseguro.uol.com.br"),
        Bank(code: "380", name: "PicPay Servicos S.A.", url: "https://www.picpay.com"),
        Bank(code: "323", name: "Mercado Pago - conta do Mercado Livre", url: "https://www.mercadopago.com.br"),
        Bank(code: "237", name: "Next Bank", url: "https://next.me"),
        Bank(code: "660", name: "Banco Votorantim S.A", url: "https://www.bv.com.br"),
        Bank(code: "660", name: "Neon Pagamentos S.A", url: "https://www.neon.com.br"),
        Bank(code: "348", name: "Banco XP S/A", url: "https://www.xpi.com.br")
    ]
}
