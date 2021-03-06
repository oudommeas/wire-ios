// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation
import TTTAttributedLabel

private let BaseLocalizationString = "content.system.cannot_decrypt"
private let IdentityString = ".identity"

class CannotDecryptCell: IconSystemCell {
    static private let generalErrorURL : NSURL = NSURL(string:"action://general-error")!
    static private let remoteIDErrorURL : NSURL = NSURL(string:"action://remote-id-error")!

    private let exclamationColor = UIColor(forZMAccentColor: .VividRed)
    
    override func configureForMessage(message: ZMConversationMessage!, layoutProperties: ConversationCellLayoutProperties!) {
        super.configureForMessage(message, layoutProperties: layoutProperties)
        leftIconView.image = UIImage(forIcon: .ExclamationMark, fontSize: 16, color: exclamationColor)
        updateLabel()
    }
    
    func updateLabel() {
        let acceptedTypes : [ZMSystemMessageType] = [.DecryptionFailed, .DecryptionFailed_RemoteIdentityChanged]
        guard let systemMessageData = message.systemMessageData,
            labelBoldFont = labelBoldFont,
            labelFont = labelFont,
            labelTextColor = labelTextColor,
            sender = message.sender
            where acceptedTypes.contains(systemMessageData.systemMessageType)
        else { return }
        
        let remoteIDChanged = systemMessageData.systemMessageType == .DecryptionFailed_RemoteIdentityChanged
        let link = remoteIDChanged ? self.dynamicType.remoteIDErrorURL : self.dynamicType.generalErrorURL

        let linkAttributes = [NSFontAttributeName: labelFont, NSLinkAttributeName: link]
        let name = localizedWhoPart(sender, remoteIDChanged: remoteIDChanged).uppercaseString
        let why = localizedWhyPart(remoteIDChanged).uppercaseString && labelFont && labelTextColor && linkAttributes
        let messageString = localizedWhatPart(remoteIDChanged, name: name).uppercaseString && labelFont && labelTextColor
        let fullString = messageString + " " + why
        
        labelView.attributedText = fullString.addAttributes([ NSFontAttributeName: labelBoldFont], toSubstring:name)
        labelView.addLinkToURL(link, withRange: NSMakeRange(messageString.length+1, why.length))
        labelView.accessibilityLabel = labelView.attributedText.string
    }
    
    func localizedWhoPart(sender: ZMUser, remoteIDChanged: Bool) -> String {
        switch (sender.isSelfUser, remoteIDChanged) {
        case (true, _):
            return (BaseLocalizationString+(remoteIDChanged ? IdentityString : "")+".you_part").localized
        case (false, true):
            return (BaseLocalizationString+IdentityString+".otherUser_part").localized(args: sender.displayName)
        case (false, false):
            return sender.displayName
        }
    }
    
    func localizedWhatPart(remoteIDChanged: Bool, name: String) -> String {
        return (BaseLocalizationString+(remoteIDChanged ? IdentityString : "")).localized(args: name)
    }
    
    func localizedWhyPart(remoteIDChanged: Bool) -> String {
        return (BaseLocalizationString+(remoteIDChanged ? IdentityString : "")+".why_part").localized
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL URL: NSURL!) {
        var url : NSURL!
        if URL.isEqual(self.dynamicType.generalErrorURL) {
            url = NSURL.wr_cannotDecryptHelpURL()
        }
        else if URL.isEqual(self.dynamicType.remoteIDErrorURL) {
            url = NSURL.wr_cannotDecryptNewRemoteIDHelpURL()
        }
        UIApplication.sharedApplication().openURL(url)
    }
}

