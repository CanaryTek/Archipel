/*
 * TNLibvirtDeviceCharacterProtocol.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <StropheCappuccino/TNXMLNode.j>

@import "TNLibvirtBase.j"

TNLibvirtDeviceCharacterProtocolTypeVIRTIO  = @"virtio";
TNLibvirtDeviceCharacterProtocolTypeRAW     = @"raw";
TNLibvirtDeviceCharacterProtocolTypeTELNET  = @"telnet";
TNLibvirtDeviceCharacterProtocolTypeTLS     = @"tls";

TNLibvirtDeviceCharacterProtocolTypes       = [ TNLibvirtDeviceCharacterProtocolTypeVIRTIO,
                                                TNLibvirtDeviceCharacterProtocolTypeRAW,
                                                TNLibvirtDeviceCharacterProtocolTypeTELNET,
                                                TNLibvirtDeviceCharacterProtocolTypeTLS];



/*! @ingroup virtualmachinedefinition
    Model for character device protocol
*/
@implementation TNLibvirtDeviceCharacterProtocol : TNLibvirtBase
{
    CPString    _type   @accessors(property=type);
}


#pragma mark -
#pragma mark Initialization

/*! initialize the object with a given XML node
    @param aNode the node to use
*/
- (id)initWithXMLNode:(TNXMLNode)aNode
{
    if (self = [super initWithXMLNode:aNode])
    {
        if ([aNode name] != @"protocol")
            [CPException raise:@"XML not valid" reason:@"The TNXMLNode provided is not a valid character device protocol"];

        _type = [aNode valueForAttribute:@"type"];
    }

    return self;
}


#pragma mark -
#pragma mark Generation

/*! return a TNXMLNode representing the object
    @return TNXMLNode
*/
- (TNXMLNode)XMLNode
{
    if (!_type)
        [CPException raise:@"Missing character device protocol type" reason:@"character device protocol type is required"];

    var node = [TNXMLNode nodeWithName:@"protocol"];

    if (_type)
        [node setValue:_type forAttribute:@"type"];

    return node;
}

@end
